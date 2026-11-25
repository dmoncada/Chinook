import Foundation
import SwiftData

public nonisolated struct CatalogImporter {
  private let source: SqliteCatalog
  private let context: ModelContext

  @concurrent
  public static func load(
    from sqliteURL: URL,
    configuration: ModelConfiguration,
  ) async throws -> ModelContainer {
    let container = try CatalogStore.open(configuration: configuration)
    let context = ModelContext(container)
    let version = 1

    let completedImport = FetchDescriptor<CatalogImport>(
      predicate: #Predicate { $0.version == version }
    )

    guard try context.fetchCount(completedImport) == 0 else {
      return container
    }

    let importer = CatalogImporter(
      source: try SqliteCatalog(url: sqliteURL),
      context: context,
    )

    let tracks = try importer.importMusic()

    try importer.importSales(tracks: tracks)

    // Commit the marker and imported rows together so a failed import can be retried.
    context.insert(CatalogImport(version: version))

    try context.save()

    return container
  }

  package static func recordCounts(in container: ModelContainer) throws -> [String: Int] {
    let context = ModelContext(container)

    func count<Model: PersistentModel>(_ model: Model.Type) throws -> Int {
      try context.fetchCount(FetchDescriptor<Model>())
    }

    return try Dictionary(
      uniqueKeysWithValues: CatalogStore.modelTypes.map { model in
        (
          String(describing: model),
          try count(model),
        )
      }
    )
  }

  private func importMusic() throws -> [Int: Track] {
    let artists = try read("SELECT ArtistId, Name FROM Artist") { row in
      try Artist(
        chinookId: row.integer(0),
        name: row.optionalText(1),
      )
    }

    let albums = try read("SELECT AlbumId, Title, ArtistId FROM Album") {
      row in
      try Album(
        chinookId: row.integer(0),
        title: row.text(1),
        artist: reference(
          row.integer(2),
          in: artists,
          table: "Artist",
        ),
      )
    }

    let genres = try read("SELECT GenreId, Name FROM Genre") { row in
      try Genre(
        chinookId: row.integer(0),
        name: row.optionalText(1),
      )
    }

    let mediaTypes = try read("SELECT MediaTypeId, Name FROM MediaType") {
      row in
      try MediaType(
        chinookId: row.integer(0),
        name: row.optionalText(1),
      )
    }

    let tracks = try read(
      """
      SELECT TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes,
             ROUND(UnitPrice * 100)
      FROM Track
      """
    ) { row in
      try Track(
        chinookId: row.integer(0),
        name: row.text(1),
        album: row.optionalInteger(2)
          .map {
            try reference($0, in: albums, table: "Album")
          },
        mediaType: reference(
          row.integer(3),
          in: mediaTypes,
          table: "MediaType",
        ),
        genre: row.optionalInteger(4)
          .map {
            try reference($0, in: genres, table: "Genre")
          },
        composer: row.optionalText(5),
        milliseconds: row.integer(6),
        bytes: row.optionalInteger(7),
        unitPriceInCents: row.integer(8),
      )
    }

    let playlists = try read("SELECT PlaylistId, Name FROM Playlist") { row in
      try Playlist(
        chinookId: row.integer(0),
        name: row.optionalText(1),
      )
    }

    try source.forEachRow("SELECT PlaylistId, TrackId FROM PlaylistTrack") { row in
      let playlist = try reference(
        row.integer(0),
        in: playlists,
        table: "Playlist",
      )

      let track = try reference(
        row.integer(1),
        in: tracks,
        table: "Track",
      )

      context.insert(
        PlaylistTrack(
          playlist: playlist,
          track: track,
        )
      )
    }

    return tracks
  }

  private func importSales(tracks: [Int: Track]) throws {
    // Chinook timestamps have no offset. SQLite interprets them as UTC.
    let employees = try read(
      """
      SELECT EmployeeId, LastName, FirstName, Title, unixepoch(BirthDate), unixepoch(HireDate),
             Address, City, State, Country, PostalCode, Phone, Fax, Email
      FROM Employee
      """
    ) { row in
      try Employee(
        chinookId: row.integer(0),
        lastName: row.text(1),
        firstName: row.text(2),
        title: row.optionalText(3),
        birthDate: row.optionalDate(4),
        hireDate: row.optionalDate(5),
        address: row.optionalText(6),
        city: row.optionalText(7),
        state: row.optionalText(8),
        country: row.optionalText(9),
        postalCode: row.optionalText(10),
        phone: row.optionalText(11),
        fax: row.optionalText(12),
        email: row.optionalText(13),
      )
    }
    try source.forEachRow(
      "SELECT EmployeeId, ReportsTo FROM Employee WHERE ReportsTo IS NOT NULL"
    ) { row in
      let employee = try reference(
        row.integer(0),
        in: employees,
        table: "Employee",
      )
      employee.manager = try reference(
        row.integer(1),
        in: employees,
        table: "Employee",
      )
    }
    let customers = try read(
      """
      SELECT CustomerId, FirstName, LastName, Company, Address, City, State, Country,
             PostalCode, Phone, Fax, Email, SupportRepId
      FROM Customer
      """
    ) { row in
      try Customer(
        chinookId: row.integer(0),
        firstName: row.text(1),
        lastName: row.text(2),
        company: row.optionalText(3),
        address: row.optionalText(4),
        city: row.optionalText(5),
        state: row.optionalText(6),
        country: row.optionalText(7),
        postalCode: row.optionalText(8),
        phone: row.optionalText(9),
        fax: row.optionalText(10),
        email: row.text(11),
        supportRepresentative: row.optionalInteger(12)
          .map {
            try reference($0, in: employees, table: "Employee")
          },
      )
    }
    let invoices = try read(
      """
      SELECT InvoiceId, CustomerId, unixepoch(InvoiceDate), BillingAddress, BillingCity,
             BillingState, BillingCountry, BillingPostalCode, ROUND(Total * 100)
      FROM Invoice
      """
    ) { row in
      try Invoice(
        chinookId: row.integer(0),
        customer: reference(
          row.integer(1),
          in: customers,
          table: "Customer",
        ),
        invoiceDate: row.date(2),
        billingAddress: row.optionalText(3),
        billingCity: row.optionalText(4),
        billingState: row.optionalText(5),
        billingCountry: row.optionalText(6),
        billingPostalCode: row.optionalText(7),
        totalInCents: row.integer(8),
      )
    }
    try source.forEachRow(
      """
      SELECT InvoiceLineId, InvoiceId, TrackId, ROUND(UnitPrice * 100), Quantity
      FROM InvoiceLine
      """
    ) { row in
      let line = try InvoiceLine(
        chinookId: row.integer(0),
        invoice: reference(
          row.integer(1),
          in: invoices,
          table: "Invoice",
        ),
        track: reference(row.integer(2), in: tracks, table: "Track"),
        unitPriceInCents: row.integer(3),
        quantity: row.integer(4),
      )
      context.insert(line)
    }
  }

  private func read<Model: PersistentModel>(
    _ sql: String,
    makeModel: (SqliteRow) throws -> Model,
  ) throws -> [Int: Model] {
    var models: [Int: Model] = [:]
    try source.forEachRow(sql) { row in
      let model = try makeModel(row)
      context.insert(model)
      // Lookup queries select the source primary key in their first column.
      models[try row.integer(0)] = model
    }
    return models
  }

  private func reference<Model>(
    _ id: Int,
    in models: [Int: Model],
    table: String,
  ) throws -> Model {
    guard let model = models[id] else {
      throw CatalogImportError.missingReference(table, id)
    }
    return model
  }
}
