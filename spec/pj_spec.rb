require File.dirname(__FILE__) + '/spec_helper.rb'

describe PJ do
  it 'should load files' do
    PJ.should respond_to(:load)
  end
  
  describe 'loading files' do
    before :each do
      @filenames = ['blah_blah_playlist.xml', 'something_else.xml', 'yet_another.xml']
      PJ::Playlist.stubs(:load)
    end
    
    it 'should accept a filename' do
      lambda { PJ.load(@filenames.first) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept multiple filenames' do
      lambda { PJ.load(*@filenames) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require at least one filename' do
      lambda { PJ.load }.should raise_error(ArgumentError)
    end
    
    it 'should load playlists for the given filenames' do
      @filenames.each do |f|
        PJ::Playlist.expects(:load).with(f)
      end
      PJ.load(*@filenames)
    end
    
    it 'should return the loaded playlists' do
      playlists = Array.new(@filenames.length) { |i|  stub("playlist #{i+1}") }
      @filenames.zip(playlists).each do |f, play|
        PJ::Playlist.stubs(:load).with(f).returns(play)
      end
      PJ.load(*@filenames).should == playlists
    end
  end
  
  it 'should have a generator' do
    PJ.should respond_to(:generator)
  end
  
  it 'should analyze playlists' do
    PJ.should respond_to(:analyze)
  end
  
  describe 'analyzing playlists' do
    before :each do
      @playlists = Array.new(3) do |i|
        tracks = Array.new(3) { |j|  stub("track #{i+1}-#{j+1}", :persistent_id => "persist_#{i+1}-#{j+1}_ola") }
        stub("playlist #{i+1}", :tracks => tracks)
      end
      @generator = Markov.new
      Markov.stubs(:new).returns(@generator)
    end
    
    it 'should accept a playlist' do
      lambda { PJ.analyze(@playlists.first) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept multiple playlists' do
      lambda { PJ.analyze(*@playlists) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require at least one playlist' do
      lambda { PJ.analyze }.should raise_error(ArgumentError)
    end
    
    it 'should create a new Markov object' do
      Markov.expects(:new).returns(@generator)
      PJ.analyze(*@playlists)
    end
    
    it 'should set the generator' do
      PJ.analyze(*@playlists)
      PJ.generator.should == @generator
    end
    
    it "should add each playlist's tracks' persistent IDs to the generator" do
      @playlists.each do |play|
        pids = play.tracks.collect { |t|  t.persistent_id }
        @generator.expects(:add).with(*pids)
      end
      PJ.analyze(*@playlists)
    end
  end
  
  it 'should import files' do
    PJ.should respond_to(:import)
  end
  
  describe 'importing files' do
    before :each do
      @filenames = ['blah_blah_playlist.xml', 'something_else.xml', 'yet_another.xml']
      PJ.stubs(:load)
      PJ.stubs(:analyze)
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
    
    it 'should load the given filenames' do
      PJ.expects(:load).with(*@filenames)
      PJ.import(*@filenames)
    end
    
    it 'should analyze the loaded playlists' do
      playlists = Array.new(@filenames.length) { |i|  stub("playlist #{i+1}") }
      PJ.stubs(:load).returns(playlists)
      PJ.expects(:analyze).with(*playlists)
      PJ.import(*@filenames)
    end
  end
end
