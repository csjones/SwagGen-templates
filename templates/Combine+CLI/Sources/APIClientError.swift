{% include "Includes/Header.stencil" %}

import Foundation

public enum APIClientError: Error {
    case unexpectedStatusCode(statusCode: Int, data: Data)
    case decodingError(DecodingError)
    case requestCreationError(Error)
    case requestCreationFailure(String)
    case requestEncodingError(Error)
    case validationError(Error)
    case networkError(URLError)
    case unknownError(Error)

    public var name:String {
        switch self {
        case .unexpectedStatusCode: return "Unexpected status code"
        case .decodingError: return "Decoding error"
        case .validationError: return "Request validation failed"
        case .requestCreationError: return "Request creation failed"
        case .requestCreationFailure: return "Request creation failed"
        case .requestEncodingError: return "Request encoding failed"
        case .networkError: return "Network error"
        case .unknownError: return "Unknown error"
        }
    }
}

extension APIClientError: CustomStringConvertible {

    public var description:String {
        switch self {
        case .unexpectedStatusCode(let statusCode, _): return "\(name): \(statusCode)"
        case .decodingError(let error): return "\(name): \(error.localizedDescription)\n\(error)"
        case .validationError(let error): return "\(name): \(error.localizedDescription)"
        case .requestCreationError(let error): return "\(name): \(error.localizedDescription)"
        case .requestCreationFailure(let description): return "\(name): \(description)"
        case .requestEncodingError(let error): return "\(name): \(error)"
        case .networkError(let error): return "\(name): \(error.localizedDescription)"
        case .unknownError(let error): return "\(name): \(error.localizedDescription)"
        }
    }
}
