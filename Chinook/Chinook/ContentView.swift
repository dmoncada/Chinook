import ChinookModels
import SwiftData
import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationStack {
      List {
        Section("Music Catalog") {
          NavigationLink(value: CatalogSection.artists) {
            Label("Artists", systemImage: "person.2")
          }
          NavigationLink(value: CatalogSection.albums) {
            Label("Albums", systemImage: "square.stack")
          }
          NavigationLink(value: CatalogSection.tracks) {
            Label("Tracks", systemImage: "music.note")
          }
        }
      }
      .navigationTitle("Chinook")
      .navigationDestination(for: CatalogSection.self) { section in
        switch section {
        case .artists:
          ArtistListView()
        case .albums:
          AlbumListView()
        case .tracks:
          TrackListView()
        }
      }
      .navigationDestination(for: Artist.self) { artist in
        AlbumListView(artist: artist)
      }
      .navigationDestination(for: Album.self) { album in
        // TrackListView(album: album)
        AlbumDetailView(album: album)
      }
      .navigationDestination(for: Track.self) { track in
        TrackDetailView(track: track)
      }
    }
  }
}

#if DEBUG
#Preview(traits: .withData) {
  ContentView()
}
#endif
