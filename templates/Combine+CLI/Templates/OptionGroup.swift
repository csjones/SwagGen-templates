{% block file_header %}MISSING BASE FILE HEADER{% endblock %}

{% block command_imports %}MISSING BASE COMMAND IMPORTS{% endblock %}
import Foundation

{% for schema in schemas where schema.type|hasSuffix:"Param" or schema.type|hasSuffix:"Params" %}
struct {{ schema.type|replace:"Param","Argument" }}: ExpressibleByArgument {
    var data: {{ schema.type }}?
    init?(argument: String) {
        self.data = try? JSONDecoder().decode({{ schema.type }}.self, from: Data(argument.utf8))
    }
}

{% endfor %}