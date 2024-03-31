class CreateUrlVisits < ActiveRecord::Migration[7.1]
  def change
    create_table :url_visits do |t|
      t.references :registered_url, null: false, foreign_key: true

      t.timestamps
    end
  end
end
