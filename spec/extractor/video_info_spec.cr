require "../spec_helper"

describe Youtube::VideoInfo do
  describe "#get_video_info" do
    it "has author" do
      Youtube::VideoInfo.new("iDfZua4IS4A").author.should eq "黑市音樂"
    end
  end
end
