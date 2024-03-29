class AddUrlVisitsCountToRegisteredUrls < ActiveRecord::Migration[7.1]
  def change
    add_column :registered_urls, :url_visits_count, :integer
  end
end
