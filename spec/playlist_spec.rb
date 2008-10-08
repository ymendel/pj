require File.dirname(__FILE__) + '/spec_helper.rb'

describe PJ::Playlist do
  before :each do
    @playlist = PJ::Playlist.new
  end
  
  it 'should have a name' do
    @playlist.should respond_to(:name)
  end
  
  it 'should allow setting the name' do
    name = 'super-cool name'
    @playlist.name = name
    @playlist.name.should == name
  end
  
  it 'should have tracks' do
    @playlist.should respond_to(:tracks)
  end
  
  it 'should allow setting the tracks' do
    tracks = [1, 5, 90, 3, 200]
    @playlist.tracks = tracks
    @playlist.tracks.should == tracks
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
        @persistent_ids = {}
        @locations = {}
        @track_info = {}
        @track_ids.each do |tid|
          @persistent_ids[tid] = "EAPERSIST#{tid}ID"
          @locations[tid] = "file://path/to/dir/for/#{tid}/file.mp3"
          @track_info[tid.to_s] = {
            'Track ID' => tid,
            'Persistent ID' => @persistent_ids[tid],
            'Location' => @locations[tid]
          }
        end
        @name = 'Test Playlist Numero Uno'
        @parsed_data = {
          'Tracks' => @track_info,
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
      
      it 'should set the playlist tracks to track objects' do
        PJ::Playlist.import(@filename).tracks.all? { |t|  t.is_a?(PJ::Track) }.should == true
      end
      
      it 'should put the track objects in the order from the file' do
        PJ::Playlist.import(@filename).tracks.collect { |t|  t.track_id }.should == @track_ids
      end
      
      it 'should set the persistent IDs for the track objects' do
        PJ::Playlist.import(@filename).tracks.collect { |t|  t.persistent_id }.should == @persistent_ids.values_at(*@track_ids)
      end
      
      it 'should set the locations for the track objects' do
        PJ::Playlist.import(@filename).tracks.collect { |t|  t.location }.should == @locations.values_at(*@track_ids)
      end
    end
  end
end
