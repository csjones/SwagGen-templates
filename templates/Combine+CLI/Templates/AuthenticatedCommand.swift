{% block file_header %}MISSING BASE FILE HEADER{% endblock %}

{% block command_imports %}MISSING BASE COMMAND IMPORTS{% endblock %}

protocol {% block protocol_authenticated_command_name %}BASE-PROTOCOL-NAME{% endblock %}: ParsableCommand {
    var auth: AuthOptions { get }
    var client: APIClient { get }
}

extension {% block extension_authenticated_command_name %}BASE-EXTENSION-NAME{% endblock %} {
    var client: APIClient {
        {% filter indent:8 %}{% block authentication_headers %}DEFAULT AUTHENTICATION HEADERS{% endblock %}{% endfilter %}
        return APIClient.default
    }
}