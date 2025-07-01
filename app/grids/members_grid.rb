class MembersGrid < ApplicationGrid
  #
  # Scope
  #
  scope do
    Member
  end

  #
  # Filters
  #
  filter(:email, :string)
  filter(:first_name, :string)
  filter(:last_name, :string)
  filter(:phone, :string)
  filter(:street, :string)
  filter(:zip, :string)
  filter(:city, :string)
  filter(:country, :enum, select: Member.distinct.pluck(:country), multiple: true)
  filter(:member_type, :enum, select: Member.distinct.pluck(:member_type).map{|type| [I18n.t("simple_form.options.defaults.member_type.#{type}"), type]}, multiple: true)

  #
  # Columns
  #
  column(:first_name)
  column(:last_name)
  column(:email)
  column(:phone)
  column(:street)
  column(:zip)
  column(:city)
  column(:country)
  column(:member_type) { |asset| I18n.t("simple_form.options.defaults.member_type.#{asset.member_type}") }

  column(:actions, html: true, header: '') do |member|
    content_tag(:div, class: 'd-flex model-buttons') do
      if current_user.admin? || current_user.member.id == member.id
        concat(
          button_to(edit_member_path(member), class: 'btn btn-primary btn-sm', method: :get) do
            icon 'pen'
          end
        )
      end
      if current_user.admin?
        concat(
          button_to(member_payments_path(member), class: 'btn btn-primary btn-sm', method: :get) do
            icon 'money-bill'
          end
        )
        concat(
          button_to(member_path(member), class: 'btn btn-danger btn-sm', method: :delete, form: { data: { turbo_confirm: t('helpers.submit.confirm') } }) do
            icon 'trash'
          end
        )
      end
    end
  end
end
