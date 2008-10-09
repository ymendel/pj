require File.dirname(__FILE__) + '/spec_helper.rb'

describe PJ do
  it 'should import files' do
    PJ.should respond_to(:import)
  end
  
  describe 'importing files' do
    before :each do
      @filenames = ['blah_blah_playlist.xml', 'something_else.xml', 'yet_another.xml']
      PJ::Playlist.stubs(:import)
    end
    
    it 'should accept a filename' do
      lambda { PJ.import(@filenames.first) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept multiple filenames' do
      lambda { PJ.import(*@filenames) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require at least one filename' do
      lambda { PJ.import }.should raise_error(ArgumentError)
    end
    
    it 'should import playlists for the given filenames' do
      @filenames.each do |f|
        PJ::Playlist.expects(:import).with(f)
      end
      PJ.import(*@filenames)
    end
    
    it 'should return the imported playlists' do
      playlists = Array.new(@filenames.length) { |i|  stub("playlist #{i+1}") }
      @filenames.zip(playlists).each do |f, play|
        PJ::Playlist.stubs(:import).with(f).returns(play)
      end
      PJ.import(*@filenames).should == playlists
    end
  end
end