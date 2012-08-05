module UsersHelper
  def gravatar_for(user, option = {size: 50})
    id = Digest::MD5::hexdigest(user.email.downcase)
    sz = option[:size]

    gravatar_url = "https://secure.gravatar.com/avatar/#{id}?s=#{sz}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
