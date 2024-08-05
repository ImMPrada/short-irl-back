module RegisteredUrls
  class Disabler
    NON_EXISTENT_URL_ERROR = 'Registered URL not found.'.freeze
    URL_TEMPORARY_SESSION_ERROR = 'URL does not belong to temporary session.'.freeze
    URL_USER_ERROR = 'URL does not belong to user.'.freeze

    def disable_for_temporary_session(temporary_session:, uuid:)
      @url_uuid = uuid
      raise StandardError, NON_EXISTENT_URL_ERROR unless registered_url.present?
      raise StandardError, URL_TEMPORARY_SESSION_ERROR unless temporary_session == registered_url.temporary_session

      deactivate_registered_url
    end

    def disable_for_user(user:, uuid:)
      @url_uuid = uuid
      raise StandardError, NON_EXISTENT_URL_ERROR unless registered_url.present?
      raise StandardError, URL_USER_ERROR unless user == registered_url.user

      deactivate_registered_url
    end

    private

    def registered_url
      @registered_url ||= RegisteredUrl.find_by(uuid: @url_uuid)
    end

    def deactivate_registered_url
      registered_url.active = false
      registered_url.expires_at = Time.zone.now
      registered_url.save!
    end
  end
end
