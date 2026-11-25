import Foundation
import SQLite3

enum StoreSnapshot {
  static func write(from source: URL, to destination: URL) throws {
    var handle: OpaquePointer?
    let sourcePath = source.path(percentEncoded: false)
    let status = sqlite3_open_v2(sourcePath, &handle, SQLITE_OPEN_READONLY, nil)

    defer { sqlite3_close(handle) }

    guard
      status == SQLITE_OK,
      let handle
    else {
      throw sqliteError(handle)
    }

    var statement: OpaquePointer?

    guard
      sqlite3_prepare_v2(handle, "VACUUM INTO ?1", -1, &statement, nil) == SQLITE_OK,
      let statement
    else {
      throw sqliteError(handle)
    }

    defer { sqlite3_finalize(statement) }

    let destinationPath = destination.path(percentEncoded: false)

    try destinationPath.withCString { path in
      // SQLite borrows the path until the statement is finalized or the binding is cleared.
      defer { sqlite3_clear_bindings(statement) }

      guard
        sqlite3_bind_text(statement, 1, path, -1, nil) == SQLITE_OK,
        sqlite3_step(statement) == SQLITE_DONE
      else {
        throw sqliteError(handle)
      }
    }
  }

  private static func sqliteError(_ database: OpaquePointer?) -> ExportError {
    let message = sqlite3_errmsg(database).map { String(cString: $0) }
    return .sqlite(message ?? "Unknown SQLite error")
  }
}
