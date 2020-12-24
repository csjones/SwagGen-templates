// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "{{ options.name }}",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .executable(name: "{{ options.cliName }}", targets: ["ApplicationEntryPoint"]),
        .library(name: "{{ options.apiName }}", targets: ["API"])
    ],
    dependencies: [
        {% for dependency in options.dependencies %}
        .package(
            // name: "{{ dependency.name }}",
            url: "https://github.com/{{ dependency.github }}.git",
            .exact("{{ dependency.version }}")
        ),
        {% endfor %}
    ],
    targets: [
        {% for target in options.targets %}
        .target(
            name: "{{ target.name }}",
            dependencies: [
                {% for dependency in target.dependencies %}
                {% if dependency.type == "target" %}.target(name: "{{ dependency.name }}"){% elif dependency.type == "product" %}.product(name: "{{ dependency.name }}", package: "{{ dependency.package }}"){% else %}"{{ dependency }}"{% endif %}{% ifnot forloop.last %},{% endif %}
                {% endfor %}
            ]{% if target.path.count > 0 %},
            path: "{{ target.path }}"{% endif %}
        ),
        {% endfor %}
    ]
)
