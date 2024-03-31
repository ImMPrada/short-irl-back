class UrlVisit < ApplicationRecord
  belongs_to :registered_url, counter_cache: true
end
