require 'spec_helper'

describe ApplicationHelper do

  describe "full_title" do
    it "should include the page title" do
      full_title("foo").should  =~ /foo/
    end

    it "should be formatted as 'site_name | page_title'" do
      full_title("fooz").should =~ /^Ruby on Rails Tutorial Sample App \| fooz$/
    end

    it "should not include a bar for the home page" do
      full_title("").should_not =~ /\|/
      full_title().should_not   =~ /\|/
    end
  end
end