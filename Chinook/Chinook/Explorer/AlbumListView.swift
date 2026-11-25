import ChinookModels
import SwiftData
import SwiftUI

struct AlbumListView: View {
  @Query private var albums: [Album]

  private let artist: Artist?

  init(artist: Artist? = nil) {
    self.artist = artist

    let sort = [
      SortDescriptor(\Album.title),
      SortDescriptor(\Album.chinookId),
    ]

    if let artist {
      let artistId = artist.chinookId
      _albums = Query(
        filter: #Predicate<Album> { $0.artist.chinookId == artistId },
        sort: sort,
      )
    } else {
      _albums = Query(sort: sort)
    }
  }

  var body: some View {
    List {
      Section {
        ForEach(albums) { album in
          NavigationLink(value: album) {
            VStack(alignment: .leading) {
              Text(album.title)
              if artist == nil, let artistName = album.artist.name {
                Text(artistName)
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }
      } header: {
        Text("Albums (\(albums.count))")
      }
    }
    .navigationTitle(artist?.name.map { Text($0) } ?? Text("Albums"))
    .overlay {
      if albums.isEmpty {
        ContentUnavailableView("No Albums", systemImage: "square.stack")
      }
    }
  }
}
