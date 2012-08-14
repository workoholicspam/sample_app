# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
  before { @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar") }

  subject { @user }

  it { should respond_to(:name)                   } #should have attribute user.name
  it { should respond_to(:email)                  } #should have attribute user.email
  it { should respond_to(:password_digest)        } #should have attribute user.password_digest
  it { should respond_to(:password)               } #should have attribute user.password
  it { should respond_to(:password_confirmation)  } #should have attribute user.password_confirmation
  it { should respond_to(:remember_token)         } #should have attribute user.remember_token
  it { should respond_to(:authenticate)           } #should have attribute user.authenticate
  it { should respond_to(:admin)                  } #should have attribute user.admin
  it { should respond_to(:microposts)             } #should have attribute user.microposts
  it { should respond_to(:feed)                   } #should have attribute user.feed

  it { should     be_valid }                        #user.valid? passes all validation required by the model
  it { should_not be_admin }

  it "should not allow mass assignment to admin" do
    expect do
      User.new(admin: true, name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar") 
    end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
  end
    
  describe "when name is not present" do
    before { @user.name = " "      }     
    it { should_not be_valid       }
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end    

    it { should be_admin }
  end











  describe "email in upcase that is saved to the database" do
    before do
      d = @user.dup
      d.email.upcase!
      d.save
    end

    let(:user_email_from_database) { User.find_by_email(@user.email.downcase).email }

    describe "should be downcase" do
      specify { user_email_from_database.should == @user.email.downcase }
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end










  describe "when email is not present" do
    before { @user.email = " "     }
    it { should_not be_valid       }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 } #50 is maximum
    it { should_not be_valid       }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email        = @user.dup
      user_with_same_email.email  = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's to short" do
    before { @user.password = @user.password = "a" * 5}
    it { should be_invalid }
  end

  describe "return value of the authenticate method" do
    before { @user.save }

    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) } #@user should equal the found user by comparison
    end

    describe "with invalid password" do
      let(:user_for_invalid_password)  {found_user.authenticate('a bad password')}

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false } #specify is simply a synonym for it, specify is used to allow us to write english "sounding" words
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank}
  end

  describe "micropost associations" do
    before { @user.save }

    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 2.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }

    its(:microposts){ should == [newer_micropost, older_micropost] }

    it "should destroy associated microposts" do
      microposts = @user.microposts
      @user.destroy

      microposts.each do |m|
        Micropost.find_by_id(m.id).should be_nil
      end
    end

    describe "status" do
      let(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }

      its(:feed) { should     include(newer_micropost) }
      its(:feed) { should     include(older_micropost) } 
      its(:feed) { should_not include(unfollowed_post) }  
    end
  end
end
