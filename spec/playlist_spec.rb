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
end
