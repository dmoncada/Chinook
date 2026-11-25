import SwiftData

@Model
nonisolated final class CatalogImport {
  var version: Int

  init(version: Int) {
    self.version = version
  }
}
