class AddMobileNumberFieldToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :mob_num, :string
  end
end
