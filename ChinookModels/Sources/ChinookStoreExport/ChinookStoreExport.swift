import ChinookModels
import Darwin
import Foundation
import SwiftData

@main
struct ChinookStoreExport {
  static func main() async {
    let arguments = CommandLine.arguments.dropFirst()
    guard arguments.count == 2 else {
      FileHandle.standardError.write(
        Data("Usage: chinook-store-export <source.sqlite> <destination.store>\n".utf8)
      )
      exit(EXIT_FAILURE)
    }

    let source = URL(filePath: arguments[arguments.startIndex])
    let destination = URL(filePath: arguments[arguments.startIndex + 1])

    do {
      let counts = try await export(from: source, to: destination)
      print("Exported \(destination.path(percentEncoded: false))")

      for (entity, count) in counts.sorted(by: { $0.key < $1.key }) {
        print("  \(entity): \(count)")
      }
    } catch {
      FileHandle.standardError.write(Data("Export failed. \(error.localizedDescription)\n".utf8))
      exit(EXIT_FAILURE)
    }
  }

  private static func export(from source: URL, to destination: URL) async throws -> [String: Int] {
    let fileManager = FileManager.default

    let workingDirectory =
      destination
      .deletingLastPathComponent()
      .appending(path: ".chinook-export-\(UUID().uuidString)", directoryHint: .isDirectory)

    try fileManager.createDirectory(at: workingDirectory, withIntermediateDirectories: false)

    defer { try? fileManager.removeItem(at: workingDirectory) }

    let importURL = workingDirectory.appending(path: "Import.store")
    let snapshotURL = workingDirectory.appending(path: "Snapshot.store")

    let container = try await CatalogImporter.load(
      from: source,
      configuration: ModelConfiguration(
        "Chinook",
        url: importURL,
        cloudKitDatabase: .none,
      ),
    )

    let importedCounts = try CatalogImporter.recordCounts(in: container)

    // The SQLite snapshot includes committed pages that are still in the import store's WAL.
    try StoreSnapshot.write(from: importURL, to: snapshotURL)

    let exportedCounts = try validateStore(at: snapshotURL)

    guard exportedCounts == importedCounts else {
      throw ExportError.incompleteSnapshot
    }

    // Moving the validated snapshot from the same directory preserves any existing output.
    try fileManager.moveItem(at: snapshotURL, to: destination)

    return exportedCounts
  }

  private static func validateStore(at url: URL) throws -> [String: Int] {
    let path = url.path(percentEncoded: false)
    let sidecars = ["-wal", "-shm", "-journal"].map { path + $0 }

    guard sidecars.allSatisfy({ !FileManager.default.fileExists(atPath: $0) }) else {
      throw ExportError.unexpectedSidecar
    }

    let container = try CatalogStore.open(
      configuration: ModelConfiguration(
        "Chinook",
        url: url,
        allowsSave: false,
        cloudKitDatabase: .none,
      )
    )

    let counts = try CatalogImporter.recordCounts(in: container)

    guard sidecars.allSatisfy({ !FileManager.default.fileExists(atPath: $0) }) else {
      throw ExportError.unexpectedSidecar
    }

    return counts
  }
}
