{% block file_header %}MISSING BASE FILE HEADER{% endblock %}

{% block command_imports %}MISSING BASE COMMAND IMPORTS{% endblock %}

protocol AuthenticatedCommand: ParsableCommand {
    var auth: AuthOptions { get }
    var client: APIClient { get }
}

extension AuthenticatedCommand {
    var client: APIClient {
        {% filter indent:8 %}{% block authentication_headers %}DEFAULT AUTHENTICATION HEADERS{% endblock %}{% endfilter %}
        return APIClient.default
    }
}