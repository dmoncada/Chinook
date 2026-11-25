// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "ChinookModels",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
    .visionOS(.v26),
  ],
  products: [
    .library(
      name: "ChinookModels",
      targets: ["ChinookModels"],
    ),
    .executable(
      name: "chinook-store-export",
      targets: ["ChinookStoreExport"],
    ),
  ],
  targets: [
    .target(name: "ChinookModels"),
    .executableTarget(
      name: "ChinookStoreExport",
      dependencies: ["ChinookModels"],
    ),
  ],
)
