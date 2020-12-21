{% block file_header %}MISSING BASE FILE HEADER{% endblock %}

{% block command_imports %}MISSING BASE COMMAND IMPORTS{% endblock %}

struct AuthOptions: ParsableArguments {
    {% filter indent:4 %}{% block authentication_options %}AUTHENTICATION OPTIONS{% endblock %}{% endfilter %}
}