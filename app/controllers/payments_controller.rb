class PaymentsController < ApplicationController

  def index
    if params[:member_id].present?
      @member = Member.find params[:member_id] 
    end
    @payments_grid = PaymentsGrid.new(params[:payments_grid]) do |scope|
      if @member
        scope.page(params[:page]).where(member: @member)
      else
        scope.page(params[:page])
      end
    end
  end

  def new
    @member = Member.find params[:member_id]
    @payment = Payment.new
  end

  def create
    @member = Member.find params[:member_id]
    @payment = Payment.new params.require(:payment).permit(:registration_id, :year, :amount_due, :amount_payed)
    @payment.member_id = params[:member_id]

    respond_to do |format|
      if @payment.save
        flash[:success] = t('messages.model.created')
        format.html { redirect_to action: 'index' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    Payment.find_by(params.permit(:id)).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to action: 'index'
  end
end
