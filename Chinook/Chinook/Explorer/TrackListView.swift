import ChinookModels
import SwiftData
import SwiftUI

struct TrackListView: View {
  private let album: Album?

  @Query private var tracks: [Track]

  init(album: Album? = nil) {
    self.album = album

    if let album {
      let albumId = album.chinookId

      _tracks = Query(
        filter: #Predicate<Track> { $0.album?.chinookId == albumId },
        sort: [SortDescriptor(\Track.chinookId)],
      )
    } else {
      _tracks = Query(sort: [
        SortDescriptor(\Track.name),
        SortDescriptor(\Track.chinookId),
      ])
    }
  }

  var body: some View {
    List {
      Section {
        ForEach(tracks) { track in
          NavigationLink(value: track) {
            VStack(alignment: .leading) {
              Text(track.name)
              if album == nil, let albumTitle = track.album?.title {
                Text(albumTitle)
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }
      } header: {
        Text("Tracks (\(tracks.count))")
      }
    }
    .navigationTitle(album.map { Text($0.title) } ?? Text("Tracks"))
    .overlay {
      if tracks.isEmpty {
        ContentUnavailableView("No Tracks", systemImage: "music.note")
      }
    }
  }
}
