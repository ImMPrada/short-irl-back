class AddUserReferenceToRegisteredUrls < ActiveRecord::Migration[7.1]
  def change
    add_reference :registered_urls, :user, null: true, foreign_key: true
  end
end
