class MemberEvent < ApplicationRecord
  belongs_to :member
  belongs_to :event
  belongs_to :registration

  before_create :set_token

  private

  def set_token
    self.token = generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.hex(32)
      break token unless MemberEvent.where(token: token).exists?
    end
  end
end
