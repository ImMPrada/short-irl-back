module RegisteredUrls
  class Creator
    def create_for_temporary_session(temporary_session:, url:)
      registered_url = temporary_session.registered_urls.new(url:)
      raise StandardError, registered_url.errors.full_messages.join(', ') unless registered_url.valid?

      unless temporary_session.valid?
        temporary_session.registered_urls.destroy(registered_url)
        raise StandardError, temporary_session.errors.full_messages.join(', ')
      end

      registered_url.save!
      temporary_session.save!
      registered_url
    end

    def create_for_user(user:, url:)
      registered_url = user.registered_urls.new(url:)
      raise StandardError, registered_url.errors.full_messages.join(', ') unless registered_url.valid?

      registered_url.save!
      registered_url
    end
  end
end
