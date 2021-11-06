class RemoveTokenFromRegistrations < ActiveRecord::Migration[6.0]
  def change
    remove_column :registrations, :token, :string, after: :id
  end
end
