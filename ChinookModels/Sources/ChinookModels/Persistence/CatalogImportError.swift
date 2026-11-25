import Foundation

nonisolated enum CatalogImportError: LocalizedError {
  case sqlite(String)
  case missingValue
  case missingReference(String, Int)

  var errorDescription: String? {
    switch self {
    case .sqlite(let message):
      "SQLite could not read the catalog. \(message)"
    case .missingValue:
      "A required value is missing from the Chinook database."
    case .missingReference(let table, let id):
      "The Chinook database refers to a missing \(table) record with ID \(id)."
    }
  }
}
