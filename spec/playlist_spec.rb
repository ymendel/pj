require File.dirname(__FILE__) + '/spec_helper.rb'

describe PJ::Playlist do
  before :each do
    @playlist = PJ::Playlist.new
  end
  
  it 'should have a name' do
    @playlist.should respond_to(:name)
  end
end
