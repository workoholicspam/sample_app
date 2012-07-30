def full_title(name = nil)
  "Ruby on Rails Tutorial Sample App" + (name.nil? ? "" : " | #{name}")
end