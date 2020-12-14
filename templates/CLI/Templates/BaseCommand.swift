{% block file_header %}MISSING BASE FILE HEADER{% endblock %}

{% block command_imports %}MISSING BASE COMMAND IMPORTS{% endblock %}

struct {% block struct_command_name %}BASE-STRUCT-NAME{% endblock %}: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "{% block command_name %}BASE COMMAND NAME{% endblock %}",
        abstract: "{% block command_abstract %}MISSING BASE COMMAND ABSTRACT{% endblock %}",
        subcommands: [
            {% filter indent:12 %}{% block subcommand_list %}BASE SUBCOMMAND LIST{% endblock %}{% endfilter %}
        ]
    )
}