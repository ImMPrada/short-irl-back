class ChangeFieldAtRegisteredUrls < ActiveRecord::Migration[7.1]
  def change
    change_column :registered_urls, :expires_at, :timestamp, null: false
  end
end
