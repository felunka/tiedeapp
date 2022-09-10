class RemoveDuplicateEmailsAndEnsureUniq < ActiveRecord::Migration[7.0]
  def up
    execute %(
      UPDATE  members mem
      SET     email = NULL
      FROM    (
        SELECT DISTINCT a.id FROM members a JOIN members b ON a.email = b.email WHERE a.id > b.id
      ) duplicates
      WHERE   duplicates.id = mem.id;
    )

    add_index :members, :email, unique: true
  end

  def down
    remove_index :members, :email
  end
end
