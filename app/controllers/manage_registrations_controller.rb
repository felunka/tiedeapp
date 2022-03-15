class ManageRegistrationsController < ApplicationController
  before_action :require_admin

  def edit
    @registration = Registration.find params[:id]
    @payments = Payment.where(registration: @registration).or(Payment.where(member: @registration.registered_members, year: @registration.event.event_start.year))
  end

  def update
    @registration = Registration.find_by params.permit(:id)

    if add_payment_amount = params.dig(:registration, :add_payment_amount)&.to_d
      # Try to pay as much as possible of the registration_fee first
      open_amount_registration = @registration.total_price - @registration.paid_amount
      if open_amount_registration > 0
        payment = Payment.new registration: @registration, member: @registration.member
        if add_payment_amount < open_amount_registration
          payment.amount = add_payment_amount
        else
          payment.amount = open_amount_registration
        end
        add_payment_amount = add_payment_amount - open_amount_registration
        payment.save!
      end

      # If there is a remaining amount, try to pay as much as possible of the membership_fees
      if add_payment_amount > 0 && @registration.membership_fee > 0
        @registration.registration_entries.each do |registration_entry|
          open_membership_fee = registration_entry.membership_fee
          if open_membership_fee > 0
            payment = Payment.new member: registration_entry.member, year: @registration.event.event_start.year
            if add_payment_amount < open_membership_fee
              payment.amount = add_payment_amount
            else
              payment.amount = open_membership_fee
            end
            add_payment_amount = add_payment_amount - open_membership_fee
            payment.save!

            break unless add_payment_amount > 0
          end
        end
      end

      # Flash warning, if the member overpayed
      if add_payment_amount > 0
        flash[:warning] = t('model.registration.error.payed_amount_too_much', overpayed_amount: ActiveSupport::NumberHelper.number_to_currency(add_payment_amount))
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
