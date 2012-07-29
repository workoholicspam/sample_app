module ApplicationHelper
  # returns full title
  def full_title(name)
    "Ruby on Rails Tutorial Sample App" + (name.nil? ? "" : " | #{name}")
  end
end
