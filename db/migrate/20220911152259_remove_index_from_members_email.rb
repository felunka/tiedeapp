class RemoveIndexFromMembersEmail < ActiveRecord::Migration[7.0]
  def change
    remove_index :members, :email
  end
end
