require 'rubygems'
require 'plist'

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
        playlist.tracks = parsed_playlist['Playlist Items'].collect { |item|  item['Track ID'] }
        playlist
      end
    end
  end
end
