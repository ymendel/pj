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
      def import(filename)
        parsed = Plist.parse_xml(filename)
        parsed_playlist = parsed['Playlists'].first
        playlist = new
        playlist.name   = parsed_playlist['Name']
        playlist.tracks = parsed_playlist['Playlist Items'].collect { |item|  track = Track.new; track.track_id = item['Track ID']; track }
        playlist
      end
    end
  end
end
