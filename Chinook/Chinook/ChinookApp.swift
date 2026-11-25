import SwiftData
import SwiftUI

@main
struct ChinookApp: App {
  @State private var catalog = CatalogLoader()

  var body: some Scene {
    WindowGroup {
      Group {
        if let container = catalog.container {
          ContentView()
            .modelContainer(container)
        } else if let error = catalog.error {
          ContentUnavailableView {
            Label(
              "Couldn’t Load Chinook",
              systemImage: "exclamationmark.circle",
            )
          } description: {
            Text(error.localizedDescription)
          } actions: {
            Button("Retry") {
              catalog.retry()
            }
          }
        } else {
          ProgressView("Loading Chinook...")
        }
      }
      .task(id: catalog.attempt) {
        await catalog.load()
      }
    }
  }
}
