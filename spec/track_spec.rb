require File.dirname(__FILE__) + '/spec_helper.rb'

describe PJ::Track do
  before :each do
    @track = PJ::Track.new
  end
  
  it 'should have a track ID' do
    @track.should respond_to(:track_id)
  end
  
  it 'should allow setting the track ID' do
    tid = 123
    @track.track_id = tid
    @track.track_id.should == tid
  end
end
