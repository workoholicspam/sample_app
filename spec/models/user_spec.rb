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
  it { should respond_to(:authenticate)           } #should have attribute user.authenticate

  it { should be_valid }                            #user.valid? passes all validation required by the model

  describe "when name is not present" do
    before { @user.name = " "      }     
    it { should_not be_valid       }
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
end