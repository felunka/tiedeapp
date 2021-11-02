class RegistrationEntry < ApplicationRecord
  belongs_to :registration

  enum user_type: {
    member: 0,
    student: 1,
    child: 2,
    guest: 3
  }
end
