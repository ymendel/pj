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
      @tracks << track
    end
    
    class << self
      def tracks
        @tracks || {}
      end
      
      def import(filename)
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
          track
        end
        playlist
      end
    end
  end
end
