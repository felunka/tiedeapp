class User < ApplicationRecord
  has_secure_password

  belongs_to :member

  delegate :email, to: :member

  validates :password, length: {in: 8..51}
  validates :password_confirmation, length: {in: 8..51}

  enum user_role: {
    member: 0,
    admin: 1
  }
end
