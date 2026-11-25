import Foundation
import SQLite3

// Column values are valid only during the row callback.
nonisolated struct SqliteRow {
  let statement: OpaquePointer

  func optionalText(_ column: Int32) -> String? {
    guard let bytes = sqlite3_column_text(statement, column) else { return nil }
    let count = Int(sqlite3_column_bytes(statement, column))
    return String(decoding: UnsafeBufferPointer(start: bytes, count: count), as: UTF8.self)
  }

  func text(_ column: Int32) throws -> String {
    guard let value = optionalText(column) else { throw CatalogImportError.missingValue }
    return value
  }

  func optionalInteger(_ column: Int32) -> Int? {
    guard sqlite3_column_type(statement, column) != SQLITE_NULL else { return nil }
    return Int(sqlite3_column_int64(statement, column))
  }

  func integer(_ column: Int32) throws -> Int {
    guard let value = optionalInteger(column) else { throw CatalogImportError.missingValue }
    return value
  }

  func optionalDate(_ column: Int32) -> Date? {
    optionalInteger(column).map { Date(timeIntervalSince1970: Double($0)) }
  }

  func date(_ column: Int32) throws -> Date {
    guard let value = optionalDate(column) else { throw CatalogImportError.missingValue }
    return value
  }
}
