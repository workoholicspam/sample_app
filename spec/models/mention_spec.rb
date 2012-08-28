require 'spec_helper'

describe Mention do
  let!(:user1)      { FactoryGirl.create(:user, name:"Sara")  }
  let!(:user2)      { FactoryGirl.create(:user, name:"gLenn") }
  let!(:user3)      { FactoryGirl.create(:user, name:"jOhN")  }
  let!(:micropost)  { user1.microposts.create!(content:"let's have lunch @glenN and @John!") }
  
  let!(:mentions)   { micropost.mentions }
  let(:mention0)    { mentions[0] }
  let(:mention1)    { mentions[1] }

  subject { mention0 }

  describe "association" do
    it "should refer to the micropost model" do
      mentions.each { |m| m.micropost.should == micropost }
    end

    it "should refer to mentioned users users" do
      mention0.mention_user.should == user2
      mention1.mention_user.should == user3
    end

    describe "destroyed" do
      it "micropost should also destroy related mentions" do
        user2.mentions.should_not be_empty
        user3.mentions.should_not be_empty
        micropost.destroy
        user2.mentions.should be_empty
        user3.mentions.should be_empty
      end

      it "user should also destroy related mentions" do
        micropost.mentions.should_not be_empty
        user2.destroy
        user3.destroy
        micropost.mentions.should be_empty
      end
    end
  end

  it "should not allow mass assignment to micropost_id" do
    expect { Mention.new(micropost_id: 99) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
  end

  describe "required attribute" do
    it "micropost should be present" do
      mention0.micropost = nil
      should_not be_valid
    end
    it "mention_user should be present" do
      mention0.mention_user = nil
      should_not be_valid
    end
  end

  describe "User feed" do
    it "should include mentions of user" do
      user2.feed.should include(micropost)
    end

    let(:user4) { FactoryGirl.create(:user) }
    it "should include mentions of people that are followed by user" do
      user4.feed.should be_empty
      user4.follow!(user3)
      user4.feed.should include(micropost)
    end
  end
end
