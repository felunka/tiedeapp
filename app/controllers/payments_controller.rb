class PaymentsController < ApplicationController

  def index
    @member = Member.find params[:member_id]
    @payments = Payment.where member: @member
  end

  def new
    @member = Member.find params[:member_id]
    @payment = Payment.new
  end

  def create
    @member = Member.find params[:member_id]
    @payment = Payment.new params.require(:payment).permit(:registration_id, :year, :amount)
    @payment.member_id = params[:member_id]

    respond_to do |format|
      if @payment.save
        flash[:success] = t('messages.model.created')
        format.html { redirect_to action: 'index' }
      else
        format.html { render :new }
      end
    end
  end

  def destroy
    @member = Member.find params[:member_id]
    Payment.find_by(params.permit(:id)).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to action: 'index'
  end
end
