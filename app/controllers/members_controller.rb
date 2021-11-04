class MembersController < ApplicationController
  def index
    @members = Member.all
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new params.require(:member).permit(:first_name, :last_name, :email, :phone, :street, :zip, :city, :country)
    if @member.save
      flash[:success] = t('messages.model.created')
      redirect_to action: 'index'
    else
      render :new
    end
  end

  def edit
    @member = Member.find_by params.permit(:id)
  end

  def update
    @member = Member.find_by params.permit(:id)
    if @member.update params.require(:member).permit(:first_name, :last_name, :email, :phone, :street, :zip, :city, :country)
      flash[:success] = t('messages.model.updated')
      redirect_to action: 'index'
    else
      render :edit
    end
  end

  def destroy
    Member.find_by(params.permit(:id)).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to action: 'index'
  end
end
