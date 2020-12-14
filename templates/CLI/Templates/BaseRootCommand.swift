{% block file_header %}MISSING BASE FILE HEADER{% endblock %}

{% block command_imports %}MISSING BASE COMMAND IMPORTS{% endblock %}

public struct {% block struct_root_command_name %}BASE-STRUCT-NAME{% endblock %}: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "{% block root_command_name %}BASE COMMAND NAME{% endblock %}",
        abstract: "{% block root_command_abstract %}MISSING BASE COMMAND ABSTRACT{% endblock %}",
        subcommands: [
            {% filter indent:12 %}{% block command_list %}BASE SUBCOMMAND LIST{% endblock %}{% endfilter %}
        ]
    )

    public init() {}
}