import Observation
import SwiftData

@MainActor
@Observable
final class CatalogLoader {
  private(set) var container: ModelContainer?
  private(set) var error: (any Error)?
  private(set) var attempt = 0

  private var isLoading = false

  func load() async {
    guard
      container == nil,
      isLoading == false
    else { return }

    defer { isLoading = false }
    isLoading = true

    do {
      container = try await BundledCatalog.openAppStore()
    } catch {
      self.error = error
    }
  }

  func retry() {
    error = nil
    attempt += 1
  }
}
