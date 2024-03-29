class PaymentsGrid < ApplicationGrid
  #
  # Scope
  #
  scope do
    Payment.joins(:member).select(%(
      payments.*,
      members.first_name,
      members.last_name
    ))
  end

  #
  # Filters
  #
  filter(:first_name, :string)
  filter(:last_name, :string)
  filter(:year, :string)

  #
  # Columns
  #
  column(:first_name, header: Member.human_attribute_name(:first_name))
  column(:last_name, header: Member.human_attribute_name(:last_name))
  column(:amount_due) { |asset| ActiveSupport::NumberHelper.number_to_currency(asset.amount_due) }
  column(:amount_payed) { |asset| ActiveSupport::NumberHelper.number_to_currency(asset.amount_payed) }
  column(:payment_type, header: I18n.t('model.payment.type')) { |asset| I18n.t "simple_form.options.defaults.payment_type.#{asset.payment_type}" }
  column(:year)
  column(:created_at) { |asset| I18n.l asset.created_at }

  actions([:destroy])
end
