import Foundation
import SQLite3

nonisolated final class SqliteCatalog {
  private let database: OpaquePointer

  init(url: URL) throws {
    var handle: OpaquePointer?

    let result = sqlite3_open_v2(
      url.path(percentEncoded: false),
      &handle,
      SQLITE_OPEN_READONLY,
      nil,
    )
    guard result == SQLITE_OK, let handle else {
      defer { sqlite3_close(handle) }
      throw CatalogImportError.sqlite(Self.message(for: handle))
    }

    database = handle
  }

  deinit {
    sqlite3_close(database)
  }

  func forEachRow(_ sql: String, _ consume: (SqliteRow) throws -> Void) throws {
    var statement: OpaquePointer?

    guard
      sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
      let statement
    else {
      throw CatalogImportError.sqlite(Self.message(for: database))
    }

    defer { sqlite3_finalize(statement) }

    var result = sqlite3_step(statement)

    while result == SQLITE_ROW {
      try consume(SqliteRow(statement: statement))
      result = sqlite3_step(statement)
    }

    guard result == SQLITE_DONE else {
      throw CatalogImportError.sqlite(Self.message(for: database))
    }
  }

  private static func message(for database: OpaquePointer?) -> String {
    guard let message = sqlite3_errmsg(database) else { return "Unknown SQLite error" }
    return String(cString: message)
  }
}
