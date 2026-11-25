import ChinookModels
import SwiftData
import SwiftUI

struct AlbumDetailView: View {
  let album: Album

  @Query private var tracks: [Track]

  init(album: Album) {
    self.album = album

    let albumId = album.chinookId

    _tracks = Query(
      filter: #Predicate<Track> { $0.album?.chinookId == albumId },
      sort: [SortDescriptor(\Track.chinookId)],
    )
  }

  var genres: [String] {
    Array(Set(tracks.compactMap(\.genre?.name)).sorted())
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text(album.title)
          .font(.title.bold())

        if let name = album.artist.name {
          Text(name)
            .font(.headline)
            .foregroundStyle(.orange)
        }

        HStack {
          ForEach(genres, id: \.self) { genre in
            Text(genre)
              .font(.caption)
              .padding(4)
              .border(.foreground)
          }
        }

        Spacer(minLength: 24)

        ThemeSection {
          Section("Tracks") {
            ForEach(tracks.enumerated(), id: \.element.id) { index, track in
              LabeledContent {
                Text(
                  Duration.milliseconds(track.milliseconds),
                  format: .time(pattern: .minuteSecond),
                )
              } label: {
                HStack(spacing: 8) {
                  Text(String(index + 1))
                  Text(track.name)
                }
              }
            }
          }
        }
      }
      .padding(.horizontal, 16)
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
      )
    }
    .scrollBounceBehavior(.basedOnSize)
  }
}

#if DEBUG
struct AlbumPreview: View {
  @Query(sort: \Album.title, order: .forward)
  private var albums: [Album]

  @State private var selectedIndex = 0

  private var selectedAlbum: Album? {
    guard albums.isEmpty == false else { return nil }
    return albums[min(selectedIndex, albums.count - 1)]
  }

  var body: some View {
    NavigationStack {
      Group {
        if let album = selectedAlbum {
          AlbumDetailView(album: album)
        } else {
          ProgressView()
        }
      }
      .navigationTitle("Albums")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            selectedIndex =
              (selectedIndex - 1 + albums.count) % albums.count
          } label: {
            Image(systemName: "chevron.left")
          }
          .disabled(albums.isEmpty)
        }

        ToolbarItem(placement: .principal) {
          Text("\(albums.isEmpty ? 0 : selectedIndex + 1) / \(albums.count)")
            .font(.caption)
            .monospacedDigit()
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            selectedIndex = (selectedIndex + 1) % albums.count
          } label: {
            Image(systemName: "chevron.right")
          }
          .disabled(albums.isEmpty)
        }
      }
    }
  }
}

#Preview(traits: .withData) {
  AlbumPreview()
}
#endif
