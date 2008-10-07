module PJ
  class Playlist
    attr_accessor :name, :tracks
    
    def initialize
      @tracks = []
    end
  end
end
