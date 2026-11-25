import SwiftData

@Model
public nonisolated final class Track {
  @Attribute(.unique)
  public var chinookId: Int
  public var name: String
  public var album: Album?
  public var mediaType: MediaType
  public var genre: Genre?
  public var composer: String?
  public var milliseconds: Int
  public var bytes: Int?
  public var unitPriceInCents: Int

  init(
    chinookId: Int,
    name: String,
    album: Album?,
    mediaType: MediaType,
    genre: Genre?,
    composer: String?,
    milliseconds: Int,
    bytes: Int?,
    unitPriceInCents: Int,
  ) {
    self.chinookId = chinookId
    self.name = name
    self.album = album
    self.mediaType = mediaType
    self.genre = genre
    self.composer = composer
    self.milliseconds = milliseconds
    self.bytes = bytes
    self.unitPriceInCents = unitPriceInCents
  }
}
