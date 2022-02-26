class AddMemberTypeAndDateOfBirthToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :member_type, :integer, default: 0, null: false
    add_column :members, :date_of_birth, :date
  end
end
