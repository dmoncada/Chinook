import Foundation

enum ExportError: LocalizedError {
  case sqlite(String)
  case incompleteSnapshot
  case unexpectedSidecar

  var errorDescription: String? {
    switch self {
    case .sqlite(let message):
      message
    case .incompleteSnapshot:
      "The exported store does not match the imported record counts."
    case .unexpectedSidecar:
      "The exported store has a SQLite sidecar file."
    }
  }
}
