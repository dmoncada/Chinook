import SwiftData

@Model
public nonisolated final class PlaylistTrack {
  public var playlist: Playlist
  public var track: Track

  #Unique<PlaylistTrack>([\.playlist, \.track])

  init(playlist: Playlist, track: Track) {
    self.playlist = playlist
    self.track = track
  }
}
