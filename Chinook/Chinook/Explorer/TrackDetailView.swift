import ChinookModels
import SwiftUI

struct TrackDetailView: View {
  let track: Track

  var body: some View {
    List {
      Section {
        Text(track.name)
          .font(.title2.bold())
          .accessibilityAddTraits(.isHeader)
      }
      Section("Track Details") {
        if let album = track.album {
          LabeledContent("Album", value: album.title)
          if let artist = album.artist.name {
            LabeledContent("Artist", value: artist)
          }
        }
        if let genre = track.genre?.name {
          LabeledContent("Genre", value: genre)
        }
        if let composer = track.composer {
          LabeledContent("Composer", value: composer)
        }
        if let mediaType = track.mediaType.name {
          LabeledContent("Media Type", value: mediaType)
        }
        LabeledContent("Duration") {
          Text(Duration.milliseconds(track.milliseconds), format: .time(pattern: .minuteSecond))
        }
      }
    }
    .navigationTitle("Track")
  }
}
