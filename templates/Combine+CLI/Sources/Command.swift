{% extends "Templates/BaseCommand.swift" %}

{% block file_header %}{% include "Includes/FileHeader.stencil" %}{% endblock %}
{% block command_imports %}{% include "Includes/CommandImports.stencil" %}{% endblock %}
{% block struct_header %}{% include "Includes/StructHeader.stencil" %}{% endblock %}
{% block struct_command_name %}{% include "Includes/StructCommandName.stencil" %}{% endblock %}
{% block command_name %}{% include "Includes/CommandName.stencil" %}{% endblock %}
{% block command_abstract %}{% include "Includes/CommandAbstract.stencil" %}{% endblock %}
{% block subcommand_list %}{% include "Includes/SubcommandList.stencil" %}{% endblock %}