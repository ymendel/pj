$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pj/playlist'
require 'rubygems'
require 'markov'

module PJ
  class << self
    attr_reader :generator
    
    def import(*files)
      raise ArgumentError, 'at least one file needed' if files.empty?
      files.collect { |f|  PJ::Playlist.import(f) }
    end
    
    def analyze(*playlists)
      raise ArgumentError, 'at least one playlist needed' if playlists.empty?
      @generator = Markov.new
      playlists.each do |play|
        pids = play.tracks.collect { |t|  t.persistent_id }
        @generator.add(*pids)
      end
    end
  end
end
