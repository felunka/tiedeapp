class AddUserRoleToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_role, :integer, null: false, default: 0, after: :id
  end
end
