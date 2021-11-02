class User < ApplicationRecord
  has_secure_password

  belongs_to :member

  delegate :email, to: :member
end
