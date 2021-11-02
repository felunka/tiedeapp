class FixTypoInMembers < ActiveRecord::Migration[6.0]
  def change
    rename_column :members, :county, :country
  end
end
