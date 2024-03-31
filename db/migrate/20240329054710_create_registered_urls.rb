class CreateRegisteredUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :registered_urls do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.string :url, null: false
      t.boolean :active, null: false
      t.numeric :expires_at, null: false

      t.references :temporary_session, null: false, foreign_key: true

      t.timestamps
    end
  end
end
