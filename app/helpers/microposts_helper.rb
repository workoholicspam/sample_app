module MicropostsHelper

  

  #returns micropost.content rendered with html, and in a desired "presentable" manner
  def present_content(micropostid_to_mentionusers, micropost)
    mention_users = micropostid_to_mentionusers[micropost.id]
    content = content_with_links_to_users(micropost.content, mention_users)
    return wrap(content)
  end


  def wrap(content)
    sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end

  private

    def wrap_long_string(text, max_width = 30)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end


    
    #returns content with links to @user
    def content_with_links_to_users(content, users)
      return content if users.nil?
      users.each { |u| content.gsub!(Regexp.new("@#{u.name}", Regexp::IGNORECASE), link_to("@#{u.name}", u)) }
      return content
    end

    #returns a hash with a key that is a micropost.id and value that is an array of users that were mentioned by the micropost.
    def get_micropostid_to_mentionusers(microposts)
      micropostid_to_mentionusers = {}
      mentions = Mention.includes(:mention_user).where(micropost_id: microposts)
      micropostids_to_mentions = mentions.group_by(&:micropost_id).each do |micropost_id, mention_list|
        micropostid_to_mentionusers[micropost_id] = mention_list.map(&:mention_user)
      end
      return micropostid_to_mentionusers
    end
end