class AddDefaultValuesToMembers < ActiveRecord::Migration[7.0]
  def change
    change_column :members, :last_name, :string, default: 'von Tiedemann'
    change_column :members, :country, :string, default: 'DE'
  end
end
