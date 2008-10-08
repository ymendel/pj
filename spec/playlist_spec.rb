require File.dirname(__FILE__) + '/spec_helper.rb'

describe PJ::Playlist do
  before :each do
    @playlist = PJ::Playlist.new
  end
  
  it 'should have a name' do
    @playlist.should respond_to(:name)
  end
  
  it 'should have tracks' do
    @playlist.should respond_to(:tracks)
  end
  
  describe 'when initialized' do
    it 'should have an empty track list' do
      PJ::Playlist.new.tracks.should == []
    end
  end
  
  it 'should allow adding to itself' do
    @playlist.should respond_to(:<<)
  end
  
  describe 'adding to itself' do
    before :each do
      @track = stub('track')
    end
    
    it 'should accept an argument' do
      lambda { @playlist << @track }.should_not raise_error(ArgumentError)
    end
    
    it 'should require an argument' do
      lambda { @playlist.send(:<<) }.should raise_error(ArgumentError)
    end
    
    it 'should append the given track to its track list' do
      @playlist << @track
      @playlist.tracks.last.should == @track
    end
    
    it 'should not change the other tracks in the track list' do
      tracks = [1, 2, 6, 7]
      @playlist.tracks = tracks.dup
      @playlist << @track
      @playlist.tracks.should == tracks + [@track]
    end
  end
  
  describe 'as a class' do
    it 'should import a file' do
      PJ::Playlist.should respond_to(:import)
    end
    
    describe 'importing a file' do
      before :each do
        @filename = 'test_playlist.xml'
        @track_ids = [123, 456, 124, 987, 567, 321, 506]
        @name = 'Test Playlist Numero Uno'
        @parsed_data = {
          'Playlists' => [
            {
              'Name' => @name,
              'Playlist Items' => @track_ids.collect { |tid|  { 'Track ID' => tid } }
            }
          ]
        }
        Plist.stubs(:parse_xml).returns(@parsed_data)
      end
      
      it 'should accept a filename' do
        lambda { PJ::Playlist.import(@filename) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a filename' do
        lambda { PJ::Playlist.import }.should raise_error(ArgumentError)
      end
      
      it 'should parse the file contents as a plist' do
        Plist.expects(:parse_xml).with(@filename).returns(@parsed_data)
        PJ::Playlist.import(@filename)
      end
      
      it 'should return a playlist' do
        PJ::Playlist.import(@filename).should be_kind_of(PJ::Playlist)
      end
      
      it 'should set the playlist name' do
        PJ::Playlist.import(@filename).name.should == @name
      end
      
      it 'should set the playlist tracks' do
        PJ::Playlist.import(@filename).tracks.should == @track_ids
      end
    end
  end
end
