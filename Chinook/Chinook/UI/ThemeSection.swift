import SwiftUI

extension ContainerValues {
  @Entry var isActive = false
}

struct ThemeSection<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(sections: content) { section in
        VStack(alignment: .leading, spacing: 0) {
          if section.header.isEmpty == false {
            section.header
              .font(.headline.bold())
              .underline(pattern: .solid)
              .padding(.bottom, Padding.xl)
          }

          Group(subviews: section.content) { rows in
            VStack(spacing: 0) {
              ForEach(rows.enumerated(), id: \.element.id) { index, row in
                // let isActive = row.containerValues.isActive

                row
                  .padding(.vertical, Padding.lg)

                if index < rows.count - 1 {
                  Divider()
                    .frame(height: LineWidth.hairline)
                    .overlay(.separator)
                }
              }
            }
          }

          if section.footer.isEmpty == false {
            section.footer
              // .withThemeSectionFooterStyle()
              .padding(.top, Padding.xl)
          }
        }
      }
    }
  }
}
