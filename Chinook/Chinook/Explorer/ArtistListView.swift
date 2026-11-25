import ChinookModels
import SwiftData
import SwiftUI

struct ArtistListView: View {
  @Query(sort: [SortDescriptor(\Artist.name), SortDescriptor(\Artist.chinookId)])
  private var artists: [Artist]

  var body: some View {
    List {
      Section {
        ForEach(artists) { artist in
          NavigationLink(value: artist) {
            if let name = artist.name {
              Text(name)
            } else {
              Text("Unknown Artist")
            }
          }
        }
      } header: {
        Text("Artists (\(artists.count))")
      }
    }
    .navigationTitle("Artists")
  }
}

#Preview("Artists", traits: .withData) {
  NavigationStack {
    ArtistListView()
  }
}
