import SwiftData

public enum CatalogStore {
  static var modelTypes: [any PersistentModel.Type] {
    [
      Artist.self,
      Album.self,
      Track.self,
      Genre.self,
      MediaType.self,
      Playlist.self,
      PlaylistTrack.self,
      Employee.self,
      Customer.self,
      Invoice.self,
      InvoiceLine.self,
      CatalogImport.self,
    ]
  }

  public static func open(configuration: ModelConfiguration) throws -> ModelContainer {
    try ModelContainer(
      for: Schema(modelTypes),
      configurations: configuration,
    )
  }
}
