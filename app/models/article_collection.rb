class ArticleCollection < ApplicationRecord
  has_many :articles, dependent: :destroy

  validates :name, :description, presence: true
end
