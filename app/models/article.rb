class Article < ApplicationRecord
  belongs_to :article_collection
  belongs_to :author, class_name: 'User'

  has_rich_text :content

  attr_readonly :author_id

  validates :title, :content, presence: true
end
