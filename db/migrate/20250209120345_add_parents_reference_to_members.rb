class AddParentsReferenceToMembers < ActiveRecord::Migration[7.0]
  def change
    add_reference :members, :parents_marriage, null: true, foreign_key: {to_table: :member_marriages}
  end
end
