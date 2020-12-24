{% extends "Templates/BaseRootCommand.swift" %}

{% block file_header %}{% include "Includes/FileHeader.stencil" %}{% endblock %}
{% block command_imports %}{% include "Includes/CommandImports.stencil" %}{% endblock %}
{% block struct_header %}{% include "Includes/StructHeader.stencil" %}{% endblock %}
{% block struct_root_command_name %}{% include "Includes/StructRootCommandName.stencil" %}{% endblock %}
{% block root_command_name %}{% include "Includes/RootCommandName.stencil" %}{% endblock %}
{% block root_command_abstract %}{% include "Includes/RootCommandAbstract.stencil" %}{% endblock %}
{% block command_list %}{% include "Includes/CommandList.stencil" %}{% endblock %}