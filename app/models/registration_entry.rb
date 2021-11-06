class RegistrationEntry < ApplicationRecord
  belongs_to :registration

  enum user_type: {
    member: 0,
    student: 1,
    child: 2,
    guest: 3
  }

  enum accommodation: {
    double_room: 0,
    single_room: 1,
    no_accommodation: 2
  }
end
