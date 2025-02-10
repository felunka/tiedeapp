class MemberMarriage < ApplicationRecord
  belongs_to :partner_1, class_name: 'Member', inverse_of: :member_marriages_as_partner_1
  belongs_to :partner_2, class_name: 'Member', inverse_of: :member_marriages_as_partner_2

  has_many :member
end
