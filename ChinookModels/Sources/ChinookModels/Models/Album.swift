import SwiftData

@Model
public nonisolated final class Album {
  @Attribute(.unique)
  public var chinookId: Int
  public var title: String
  public var artist: Artist

  init(chinookId: Int, title: String, artist: Artist) {
    self.chinookId = chinookId
    self.title = title
    self.artist = artist
  }
}
