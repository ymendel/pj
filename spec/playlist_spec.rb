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
end
