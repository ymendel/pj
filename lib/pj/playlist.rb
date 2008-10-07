module PJ
  class Playlist
    attr_accessor :name, :tracks
    
    def initialize
      @tracks = []
    end
    
    def <<(track)
      @tracks << track
    end
  end
end
