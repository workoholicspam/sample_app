require 'spec_helper'

describe "Static pages" do
  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('title', text: full_title(page_title) ) }
    it { should have_selector('h1',    text: page_heading           ) }
  end

  describe "Home page" do
    before { visit root_path }

    let(:page_title)      { ''            }
    let(:page_heading)    { 'Sample App'  }

    it_should_behave_like "all static pages"
    it { should_not have_selector('title',  text: '| Home') }

    describe "for signed in users" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        FactoryGirl.create(:micropost, user: user, content: "hi momma")
        FactoryGirl.create(:micropost, user: user, content: "whatcha doin")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end

      end

      describe "side bar" do
        it "should have correct pluralization of 'micropost'" do
          page.should have_content('microposts')
        end

        it { should have_content(user.microposts.count) }
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    
    let(:page_title)      { 'Help'        }
    let(:page_heading)    { 'Help'        }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }

    let(:page_title)      { 'About Us'    }
    let(:page_heading)    { 'About Us'    }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    
    let(:page_title)      { 'Contact'     }
    let(:page_heading)    { 'Contact'     }

    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path

    click_link 'About'
    page.should have_selector('title', text: full_title('About Us'))

    click_link 'Help' #from about click help
    page.should have_selector('title', text: full_title('Help'))

    click_link 'Contact' #from help click contact
    page.should have_selector('title', text: full_title('Contact'))

    click_link 'Home' #from contact click home
    click_link 'Sign up now' #from home click sign up now
    page.should have_selector('title', text: full_title(''))

    click_link 'sample app' #from sign up now click sample app
    page.should have_selector('title', text: full_title(''))
  end
end
