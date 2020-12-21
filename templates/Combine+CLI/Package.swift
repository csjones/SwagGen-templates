// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "{{ options.name }}",
    // platforms: [
    //     .iOS(.v13),
    //     .macOS(.v10_15),
    //     .tvOS(.v13),
    //     .watchOS(.v6),
    // ],
    products: [
        .executable(name: "{{ options.name }}", targets: ["ApplicationEntryPoint"])
        .library(name: "{{ options.name }}", targets: ["{{ options.name }}"])
    ],
    dependencies: [
        {% for dependency in options.dependencies %}
        .package(url: "https://github.com/{{ dependency.github }}.git", .exact("{{ dependency.version }}")),
        {% endfor %}
    ],
    targets: [
        {% for target in options.targets %}
        .target(
            name: "{{ target.name }}",
            dependencies: [
                {% for dependency in options.dependencies %}
                {{ dependency }}
                {% endfor %}
            ]
        ),
        {% endfor %}
        // .target(name: "{{ options.name }}", dependencies: [
        //   {% for dependency in options.dependencies %}
        //   "{{ dependency.pod }}",
        //   {% endfor %}
        // ], path: "Sources")
    ]
)
