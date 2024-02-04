class ManageRegistrationsController < ApplicationController
  before_action :require_admin

  def edit
    @registration = Registration.find params[:id]
    @payments = Payment.where(registration: @registration).or(Payment.where(member: @registration.registered_members, year: @registration.event.event_start.year))
  end

  def update
    @registration = Registration.find_by params.permit(:id)

    if add_payment_amount = params.dig(:registration, :add_payment_amount)&.to_d
      @registration.payment.amount_payed += add_payment_amount
      @registration.payment.save!

      # Flash warning, if the member overpayed
      overpay_amout = @registration.payment.amount_payed - @registration.payment.amount_due
      if overpay_amout > 0
        flash[:warning] = t('model.registration.error.payed_amount_too_much', overpayed_amount: ActiveSupport::NumberHelper.number_to_currency(overpay_amout))
      end
    end

    respond_to do |format|
      if @registration.update permit(params)
        format.html { redirect_to edit_manage_registration_path(@registration) }
      else
        @payments = Payment.where(registration: @registration).or(Payment.where(member: @registration.registered_members, year: @registration.event.event_start.year))
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def permit(params)
    params.require(:registration).permit(:registration_state, :add_payment_amount)
  end
end
