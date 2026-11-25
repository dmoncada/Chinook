import SwiftData

@Model
public nonisolated final class Artist {
  @Attribute(.unique)
  public var chinookId: Int
  public var name: String?

  init(chinookId: Int, name: String?) {
    self.chinookId = chinookId
    self.name = name
  }
}
