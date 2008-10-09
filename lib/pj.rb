$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pj/playlist'

module PJ
  class << self
    def import(*files)
      raise ArgumentError, 'at least one file needed' if files.empty?
      files.collect { |f|  PJ::Playlist.import(f) }
    end
  end
end
