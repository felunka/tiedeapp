class AddHiddenFlagToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :hidden, :boolean, default: false
  end
end
