class AddFiledsToUsers < ActiveRecord::Migration
  def change
  
        add_column :users, :password_digest, :string
        add_column :users, :authy_id, :string
        add_column :users, :country_code, :string
  end
end
