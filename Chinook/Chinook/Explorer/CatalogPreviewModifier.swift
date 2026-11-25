import DeveloperToolsSupport
import SwiftData
import SwiftUI

struct CatalogPreviewModifier: PreviewModifier {
  static func makeSharedContext() async throws -> ModelContainer {
    try await BundledCatalog.openPreviewStore()
  }

  func body(content: Content, context: ModelContainer) -> some View {
    content.modelContainer(context)
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  static var withData: Self {
    .modifier(CatalogPreviewModifier())
  }
}
