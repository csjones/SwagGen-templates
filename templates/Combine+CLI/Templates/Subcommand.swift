{% block file_header %}MISSING BASE FILE HEADER{% endblock %}

{% block command_imports %}MISSING BASE COMMAND IMPORTS{% endblock %}

{% block struct_header %}MISSING BASE STRUCT HEADER{% endblock %}
struct {% block struct_subcommand_name %}BASE-STRUCT-NAME{% endblock %}: {% block struct_subcommand_protocol %}STRUCT-SUBCOMMAND-PROTOCOL{% endblock %} {
    static var configuration = CommandConfiguration(
        commandName: "{% block subcommand_name %}MISSING BASE COMMAND NAME{% endblock %}",
        abstract: "{% block command_abstract %}MISSING BASE COMMAND ABSTRACT{% endblock %}"
    )

    {% filter indent:4 %}{% block authentication_properties %}AUTHENTICATION PROPERTIES{% endblock %}{% endfilter %}
    {% filter indent:4 %}{% block subcommand_properties %}SUBCOMMAND PROPERTIES{% endblock %}{% endfilter %}

    func run() throws {
        let request = {% block subcommand_request %}SUBCOMMAND REQUEST{% endblock %}

        client
            .call(request)
            .waitUntilDone()
    }
}

{% block subcommand_extension %}SUBCOMMAND EXTENSION{% endblock %}