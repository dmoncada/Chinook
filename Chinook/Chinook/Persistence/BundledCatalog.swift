import ChinookModels
import Foundation
import SwiftData

nonisolated enum BundledCatalog {
  private static let name = "Chinook"

  @concurrent
  static func openAppStore() async throws -> ModelContainer {
    let fileManager = FileManager.default
    let directory = URL.applicationSupportDirectory
    let destination = directory.appending(path: "\(name).store", directoryHint: .notDirectory)

    if fileManager.fileExists(atPath: destination.path(percentEncoded: false)) == false {
      let source = try seedUrl()
      try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
      let staged = directory.appending(path: ".\(name)-\(UUID().uuidString).tmp")

      defer { try? fileManager.removeItem(at: staged) }

      // Publish the store only after the entire seed has been copied.
      try fileManager.copyItem(at: source, to: staged)

      do {
        try fileManager.moveItem(at: staged, to: destination)
      } catch let error as CocoaError where error.code == .fileWriteFileExists {
        // Another opener already installed the seed.
      }
    }

    return try CatalogStore.open(
      configuration: ModelConfiguration(
        name,
        url: destination,
        cloudKitDatabase: .none,
      )
    )
  }

  @concurrent
  static func openPreviewStore() async throws -> ModelContainer {
    try CatalogStore.open(
      configuration: ModelConfiguration(
        name,
        url: try seedUrl(),
        allowsSave: false,
        cloudKitDatabase: .none,
      )
    )
  }

  private static func seedUrl() throws -> URL {
    guard
      let url = Bundle.main.url(
        forResource: name,
        withExtension: "store",
      )
    else {
      throw CocoaError(
        .fileNoSuchFile,
        userInfo: [NSLocalizedDescriptionKey: "The bundled Chinook store could not be found."],
      )
    }
    return url
  }
}
