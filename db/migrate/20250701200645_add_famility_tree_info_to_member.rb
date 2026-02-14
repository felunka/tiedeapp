class AddFamilityTreeInfoToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :family_tree_comment, :string
    add_column :members, :family_house_origin, :integer
  end
end
