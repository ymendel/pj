require File.dirname(__FILE__) + '/spec_helper.rb'

describe PJ::Track do
  before :each do
    @track = PJ::Track.new
  end
  
  it 'should have a track ID' do
    @track.should respond_to(:track_id)
  end
end
