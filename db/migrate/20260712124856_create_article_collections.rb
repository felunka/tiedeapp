class CreateArticleCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :article_collections do |t|
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
