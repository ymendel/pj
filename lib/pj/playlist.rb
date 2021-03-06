require 'rubygems'
require 'plist'
require 'pj/track'

module PJ
  class Playlist
    attr_accessor :name, :tracks
    
    def initialize
      @tracks = []
    end
    
    def <<(track)
      if stored_track = self.class.tracks[track]
        track = stored_track
      end
      @tracks << track
    end
    
    def to_hash
      tracks_hash = {}
      tracks.each do |t|
        tracks_hash[t.track_id.to_s] = {
          'Track ID'      => t.track_id,
          'Persistent ID' => t.persistent_id,
          'Location'      => t.location
        }
      end
      {
        'Tracks' => tracks_hash,
        'Playlists' => [{
          'Name' => name.to_s,
          'Playlist Items' => tracks.collect { |t|  { 'Track ID' => t.track_id } }
        }]
      }
    end
    
    def write(filename)
      h = to_hash
      File.open(filename, 'w') do |f|
        f.puts Plist::Emit.wrap([
          "<dict>",
          "<key>Tracks</key>",
          h['Tracks'].to_plist(false),
          "<key>Playlists</key>",
          h['Playlists'].to_plist(false),
          "</dict>"].join("\n"))
      end
    end
    
    class << self
      def tracks
        @tracks ||= {}
      end
      
      def store_track(track)
        tracks[track.persistent_id] = track
      end
      
      def load(filename)
        parsed = Plist.parse_xml(filename)
        parsed_playlist = parsed['Playlists'].first
        parsed_tracks   = parsed['Tracks']
        playlist = new
        playlist.name   = parsed_playlist['Name']
        playlist.tracks = parsed_playlist['Playlist Items'].collect do |item|
          track_info = parsed_tracks[item['Track ID'].to_s]
          track = Track.new
          track.track_id      = item['Track ID']
          track.persistent_id = track_info['Persistent ID']
          track.location      = track_info['Location']
          track.name          = track_info['Name']
          store_track(track)
          track
        end
        playlist
      end
    end
  end
end
