{% include "Includes/Header.stencil" %}

import Combine
import Foundation

public typealias CallPublisher<Success> = AnyPublisher<Success, Error>
public typealias APIResponsePublisher<T: APIResponseValue> = AnyPublisher<APIResponse<T>, Never>

/// Holds API client errors and context until they're ready to be returned as `APIResponse<T>` objects.
internal struct ErrorResponse<T: APIResponseValue>: Error {
    let apiResponse: APIResponse<T>
}

/// Manages and sends APIRequests
public class APIClient {

    public static var `default` = APIClient(baseURL: MastodonC2S.Server.main)

    /// A list of RequestBehaviours that can be used to monitor and alter all requests
    public var behaviours: [RequestBehaviour] = []

    /// The base url prepended before every request path
    public var baseURL: String

    /// The URLSession used for each request
    public var session: URLSession

    /// These headers will get added to every request
    public var defaultHeaders: [String: String]

    public var jsonDecoder = JSONDecoder()

    public init(baseURL: String, session: URLSession = .shared, defaultHeaders: [String: String] = [:], behaviours: [RequestBehaviour] = []) {
        self.baseURL = baseURL
        self.session = session
        self.behaviours = behaviours
        self.defaultHeaders = defaultHeaders
        jsonDecoder.dateDecodingStrategy = .custom(dateDecoder)
    }
    
    /// Call an API service with a single failure type.
    /// Publishes `T.SuccessType` if successful.
    /// On an `APIClientError`, will throw that.
    /// On an API error response, will throw `T.FailureType` if it extends `Error`, and throw `APIError<T.FailureType>` wrapping it otherwise.
    public func call<T: SingleFailureType>(_ request: APIRequest<T>, behaviours: [RequestBehaviour] = []) -> CallPublisher<T.SuccessType> {
        makeRequest(request, behaviours: behaviours)
            .tryMap { apiResponse in try apiResponse.result.get().responseResult.get() }
            .eraseToAnyPublisher()
    }
    
    /// Call an API service with no failure type or multiple failure types.
    /// Publishes `T.SuccessType` if successful.
    /// On an `APIClientError`, will throw that.
    /// On an API error response, will throw one of the service's failure types if it extends `Error`, and throw `APIError<Any>` wrapping it otherwise.
    public func call<T>(_ request: APIRequest<T>, behaviours: [RequestBehaviour] = []) -> CallPublisher<T.SuccessType> {
        makeRequest(request, behaviours: behaviours)
            .tryMap { apiResponse in
                let apiResponseValue = try apiResponse.result.get()
                if let success = apiResponseValue.success {
                    return success
                }
                let failure = apiResponseValue.response
                if let error = failure as? Error {
                    throw error
                }
                throw APIError<Any>(failure: failure)
            }
            .eraseToAnyPublisher()
    }

    /// Makes a network request and returns a detailed response. Lower-level than `APIClient.call`.
    ///
    /// - Parameters:
    ///   - request: The API request to make
    ///   - behaviours: A list of behaviours that will be run for this request. Merged with `APIClient.behaviours`.
    /// - Returns: A request response publisher
    public func makeRequest<T>(_ request: APIRequest<T>, behaviours: [RequestBehaviour] = []) -> APIResponsePublisher<T> {
        // create composite behaviour to make it easy to call functions on array of behaviours
        let requestBehaviour = RequestBehaviourGroup(request: request, behaviours: self.behaviours + behaviours)

        // Try to create the URLRequest from the request.
        return Result { try request.createURLRequest(baseURL) }
            .publisher
            .eraseToAnyPublisher()
            .mapError { error in
                let apiResponse = APIResponse<T>(request: request, result: .failure(.requestCreationError(error)))
                return ErrorResponse(apiResponse: apiResponse)
            }
            
            // Modify the URLRequest for this client.
            .flatMap { urlRequest -> AnyPublisher<URLRequest, ErrorResponse<T>> in
                var urlRequest = urlRequest
                urlRequest.allHTTPHeaderFields = urlRequest.allHTTPHeaderFields?.merging(self.defaultHeaders) { request, client in client }
                urlRequest = requestBehaviour.modifyRequest(urlRequest)
                return requestBehaviour
                    .validate(urlRequest)
                    .mapError { error -> ErrorResponse<T> in
                        let apiResponse = APIResponse<T>(request: request, result: .failure(.validationError(error)), urlRequest: urlRequest)
                        return ErrorResponse(apiResponse: apiResponse)
                    }
                    .eraseToAnyPublisher()
            }

            // Make the network request.
            .flatMap { urlRequest in
                self.makeNetworkRequest(request: request, urlRequest: urlRequest, requestBehaviour: requestBehaviour)
            }
        
            // Handle the response.
            .map { urlRequest, data, urlResponse in
                self.handleResponse(request: request, urlRequest: urlRequest, requestBehaviour: requestBehaviour, data: data, urlResponse: urlResponse as! HTTPURLResponse)
            }
            
            // Handle errors.
            .catch { error -> Just<APIResponse<T>> in
                if case let .failure(error) = error.apiResponse.result {
                    requestBehaviour.onFailure(error: error)
                }
                return Just(error.apiResponse)
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    private func makeNetworkRequest<T>(request: APIRequest<T>, urlRequest: URLRequest, requestBehaviour: RequestBehaviourGroup) -> AnyPublisher<(URLRequest, Data, URLResponse), ErrorResponse<T>> {
        requestBehaviour.beforeSend()

        if request.service.isUpload {
            fatalError("Upload services not supported yet") // TODO: request.service.isUpload
//            sessionManager.upload(
//                multipartFormData: { multipartFormData in
//                    for (name, value) in request.formParameters {
//                        if let file = value as? UploadFile {
//                            switch file.type {
//                            case let .url(url):
//                                if let fileName = file.fileName, let mimeType = file.mimeType {
//                                    multipartFormData.append(url, withName: name, fileName: fileName, mimeType: mimeType)
//                                } else {
//                                    multipartFormData.append(url, withName: name)
//                                }
//                            case let .data(data):
//                                if let fileName = file.fileName, let mimeType = file.mimeType {
//                                    multipartFormData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
//                                } else {
//                                    multipartFormData.append(data, withName: name)
//                                }
//                            }
//                        } else if let url = value as? URL {
//                            multipartFormData.append(url, withName: name)
//                        } else if let data = value as? Data {
//                            multipartFormData.append(data, withName: name)
//                        }
//                    }
//                },
//                with: urlRequest,
//                encodingCompletion: { result in
//                    switch result {
//                    case .success(let uploadRequest, _, _):
//                        cancellableRequest.networkRequest = uploadRequest
//                        uploadRequest.responseData { dataResponse in
//                            self.handleResponse(request: request, requestBehaviour: requestBehaviour, dataResponse: dataResponse, completionQueue: completionQueue, complete: complete)
//                        }
//                    case .failure(let error):
//                        let apiError = APIClientError.requestEncodingError(error)
//                        requestBehaviour.onFailure(error: apiError)
//                        let response = APIResponse<T>(request: request, result: .failure(apiError))
//
//                        completionQueue.async {
//                            complete(response)
//                        }
//                    }
//            })
        } else {
            return session
                .dataTaskPublisher(for: urlRequest)
                .map { data, urlResponse in (urlRequest, data, urlResponse) }
                .mapError { ErrorResponse(apiResponse: APIResponse<T>(request: request, result: .failure(.networkError($0)), urlRequest: urlRequest)) }
                .eraseToAnyPublisher()
        }
    }

    private func handleResponse<T>(request: APIRequest<T>, urlRequest: URLRequest, requestBehaviour: RequestBehaviourGroup, data: Data, urlResponse: HTTPURLResponse) -> APIResponse<T> {
        
        let result: APIResult<T>
        
        let statusCode = urlResponse.statusCode
        do {
            let decoded = try T(statusCode: statusCode, data: data, decoder: jsonDecoder)
            result = .success(decoded)
            if decoded.successful {
                requestBehaviour.onSuccess(result: decoded.response as Any)
            }
        } catch let error as DecodingError {
            result = .failure(APIClientError.decodingError(error))
        } catch {
            result = .failure(APIClientError.unknownError(error))
        }

        let response = APIResponse<T>(request: request, result: result, urlRequest: urlRequest, urlResponse: urlResponse, data: data, metrics: nil) // TODO: metrics
        requestBehaviour.onResponse(response: response.asAny())
        
        return response
    }
}

// Helper extension for sending requests
extension APIRequest {

    /// makes a request using the default APIClient. Change your baseURL in APIClient.default.baseURL
    public func makeRequest() -> APIResponsePublisher<ResponseType> {
        APIClient.default.makeRequest(self)
    }
}

// Create URLRequest
extension APIRequest {

    /// pass in an optional baseURL, otherwise URLRequest.url will be relative
    public func createURLRequest(_ baseURL: String = "") throws -> URLRequest {
        guard var urlComponents = URLComponents(string: "\(baseURL)\(path)") else {
            throw APIClientError.requestCreationFailure("Couldn't parse request path as URL")
        }
    
        urlComponents.queryItems = filterParams(queryParameters)
        
        guard let url = urlComponents.url else {
            throw APIClientError.requestCreationFailure("Couldn't construct request URL")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = service.method

        if !formParameters.isEmpty {
            // Encode form parameters in body.
            var formEncoder = URLComponents()
            formEncoder.queryItems = filterParams(formParameters)
            guard let formData = formEncoder
                .percentEncodedQuery?
                .replacingOccurrences(of: "%20", with: "+")
                .data(using: .utf8)
                else { throw APIClientError.requestCreationFailure("Couldn't construct request body") }
            urlRequest.httpBody = formData
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        } else if let encodeBody = encodeBody {
            // Encode body as JSON.
            urlRequest.httpBody = try encodeBody()
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }

    // TODO: support OpenAPI 3 allowEmptyValue
    /// filter out parameters with empty string value
    func filterParams(_ params: [String: Any]) -> [URLQueryItem]? {
        let urlQueryItems: [URLQueryItem] = params.compactMap { name, value in
            let value = String(describing: value)
            guard !value.isEmpty else { return nil }
            return URLQueryItem(name: name, value: value)
        }
        guard !urlQueryItems.isEmpty else { return nil }
        return urlQueryItems
    }
}
