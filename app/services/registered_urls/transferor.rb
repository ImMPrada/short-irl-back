module RegisteredUrls
  class Transferor
    def transfer_to_user(user:, temporary_session_uuid:)
      temporary_session = TemporarySession.find_by(uuid: temporary_session_uuid)
      return unless temporary_session.present?

      registered_urls = temporary_session.registered_urls

      registered_urls.each { |registered_url| user.registered_urls << registered_url }

      user.save
      temporary_session.destroy
    end
  end
end
