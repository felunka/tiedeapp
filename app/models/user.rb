class User < ApplicationRecord
  has_secure_password

  belongs_to :member

  delegate :email, to: :member

  enum user_role: {
    member: 0,
    admin: 1
  }
end
