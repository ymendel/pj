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
    
    it 'should add a stored track if given a known persistent ID' do
      track = PJ::Track.new
      track.track_id = 12
      track.persistent_id = 'eab3901-do'
      track.location = 'file://path/to/file.mp3'
      PJ::Playlist.store_track(track)
      
      @playlist << track.persistent_id
      @playlist.tracks.should include(track)
    end
  end
  
  it 'should have a hash representation' do
    @playlist.should respond_to(:to_hash)
  end
  
  describe 'hash representation' do
    before :each do
      @playlist.name = 'Super-Duper-Cool-Awesome'
      @tracks = Array.new(5) do |i|
        track = PJ::Track.new
        track.track_id = i + 1
        track.persistent_id = "persist_#{i+1}_ola"
        track.location = "file://path/to/track_#{i+1}_file.mp3"
        track
      end
      @playlist.tracks = @tracks
    end
    
    it 'should return a hash' do
      @playlist.to_hash.should be_kind_of(Hash)
    end
    
    it 'should include a playlist section' do
      @playlist.to_hash.should include('Playlists')
    end
    
    describe 'playlist section' do
      before :each do
        @playlist_section = @playlist.to_hash['Playlists']
      end
      
      it 'should be an array' do
        @playlist_section.should be_kind_of(Array)
      end
      
      it 'should contain one hash' do
        @playlist_section.length.should == 1
        @playlist_section.first.should be_kind_of(Hash)
      end
      
      describe 'playlist data' do
        before :each do
          @playlist_data = @playlist_section.first
        end
        
        it 'should contain its name' do
          @playlist_data['Name'].should == @playlist.name
        end
        
        it 'should contain its tracks' do
          @playlist_data.should include('Playlist Items')
        end
        
        describe 'playlist items' do
          before :each do
            @playlist_items = @playlist_data['Playlist Items']
          end
          
          it 'should be an array' do
            @playlist_items.should be_kind_of(Array)
          end
          
          it "should contain { 'Track ID' => track_id } hashes for the tracks" do
            track_hashes = @playlist.tracks.collect { |t|  { 'Track ID' => t.track_id } }
            @playlist_items.should == track_hashes
          end
        end
      end
    end
    
    it 'should include a track section' do
      @playlist.to_hash.should include('Tracks')
    end
    
    describe 'track section' do
      before :each do
        @track_section = @playlist.to_hash['Tracks']
      end
      
      it 'should be a hash' do
        @track_section.should be_kind_of(Hash)
      end
      
      it 'should have a key for each track ID (as a string)' do
        @track_section.keys.sort.should == @tracks.collect { |t|  t.track_id.to_s }
      end
      
      describe 'data for a single track' do
        before :each do
          @track = @tracks.first
          @track_data = @playlist.to_hash['Tracks'][@track.track_id.to_s]
        end
        
        it 'should be a hash' do
          @track_data.should be_kind_of(Hash)
        end
        
        it 'should include the track ID' do
          @track_data['Track ID'].should == @track.track_id
        end
        
        it 'should include the persistent ID' do
          @track_data['Persistent ID'].should == @track.persistent_id
        end
        
        it 'should include the location' do
          @track_data['Location'].should == @track.location
        end
      end
    end
  end
  
  describe 'as a class' do
    describe 'handling known tracks' do
      before :each do
        class << PJ::Playlist
          attr_writer :tracks
        end
      end
      
      it 'should have known tracks' do
        PJ::Playlist.should respond_to(:tracks)
      end
      
      it 'should return known tracks' do
        tracks = { '1' => 'some track', 'five' => 'track five'}
        PJ::Playlist.tracks = tracks
        PJ::Playlist.tracks.should == tracks
      end
      
      it 'should default known tracks to an empty hash' do
        PJ::Playlist.tracks = nil
        PJ::Playlist.tracks.should == {}
      end
      
      it 'should allow for storing a track' do
        PJ::Playlist.should respond_to(:store_track)
      end
      
      describe 'storing a track' do
        before :each do
          @track = PJ::Track.new
          @track.track_id = 12
          @track.persistent_id = 'eab3901-do'
          @track.location = 'file://path/to/file.mp3'
        end
        
        it 'should accept a track' do
          lambda { PJ::Playlist.store_track(@track) }.should_not raise_error(ArgumentError)
        end
        
        it 'should require a track' do
          lambda { PJ::Playlist.store_track }.should raise_error(ArgumentError)
        end
        
        it 'should store the track, keyed by persistent ID' do
          PJ::Playlist.store_track(@track)
          PJ::Playlist.tracks[@track.persistent_id].should == @track
        end
        
        it 'should not affect other tracks' do
          tracks = { '1' => 'some track', 'five' => 'track five'}
          keys = tracks.keys.dup
          PJ::Playlist.tracks = tracks
          PJ::Playlist.store_track(@track)
          PJ::Playlist.tracks.keys.sort.should == (keys + [@track.persistent_id]).sort
        end
      end
    end
    
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
      
      it 'should store the track objects' do
        pids = @persistent_ids.values_at(*@track_ids)
        PJ::Playlist.import(@filename)
        PJ::Playlist.tracks.values_at(*pids).collect { |t|  t.persistent_id }.should == pids
      end
    end
  end
end
