import ProjectDescription

let project = Project(
    name: "IosNetworking",
    targets: [
        .target(
            name: "IosNetworking",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tbx.IosNetworking",
            sources: ["IosNetworking/Sources/**"],
            dependencies: []
        ),
    ]
)
