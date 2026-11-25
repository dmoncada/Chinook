import ChinookModels
import Foundation
import SnapshotTesting
import SwiftData
import SwiftUI
import Testing

@testable import Chinook

@MainActor
struct ChinookTests {
  @Test func albumDetail() async throws {
    let container = try await BundledCatalog.openPreviewStore()
    let albumId = 4 // Let There Be Rock by AC/DC.
    let albums = try container.mainContext.fetch(
      FetchDescriptor<Album>(predicate: #Predicate { $0.chinookId == albumId })
    )
    let album = try #require(albums.first)

    let view = AlbumDetailView(album: album)
      .modelContainer(container)
      .environment(\.locale, Locale(identifier: "en_US"))
      .environment(\.colorScheme, .light)
      .dynamicTypeSize(.large)

    assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 844)))
  }
}
