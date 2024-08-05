class AddConfirmPasswordToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :confirm_password, :string, null: false
  end
end
