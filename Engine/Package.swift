// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Engine",
    platforms:[
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "DiagramModel", targets: ["DiagramModel"]),
        .library(name: "DiagramConversion", targets: ["DiagramConversion"]),
        .library(name: "DiagramCompilation", targets: ["DiagramCompilation"]),
        .library(name: "ProjectVersion", targets: ["ProjectVersion"]),
    ],
    dependencies: [
            .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],                  
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DiagramCompilation"
        ),
        .target(
            name: "DiagramConversion",
            dependencies: ["DiagramModel", "ProjectVersion"]
        ),
        .target(
            name: "DiagramModel"
        ),
        .target(name: "ProjectVersion"),
        .testTarget(
            name: "DiagramModelTests",
            dependencies: ["DiagramModel"]
        ),
        .testTarget(
            name: "DiagramConversionTests",
            dependencies: ["DiagramConversion", "DiagramModel"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
