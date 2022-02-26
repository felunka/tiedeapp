class MembersController < ApplicationController
  before_action :require_admin, only: [:new, :create, :destroy]

  def index
    @members = Member.all
  end

  def autocomplete
    @members = Member.where("CONCAT_WS(' ', first_name, last_name) ILIKE ?", "#{params[:term]}%").limit(10).map do |model|
      { id: model.id, text: model.full_name }
    end

    respond_to do |format|
      format.json { render json: @members }
    end 
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new permit(params)
    if @member.save
      flash[:success] = t('messages.model.created')
      redirect_to action: 'index'
    else
      render :new
    end
  end

  def edit
    raise ApplicationController::NotAuthorized unless current_user.admin? || current_user.member.id == params[:id].to_i

    @member = Member.find_by params.permit(:id)
  end

  def update
    raise ApplicationController::NotAuthorized unless current_user.admin? || current_user.member.id == params[:id].to_i

    @member = Member.find_by params.permit(:id)
    if @member.update permit(params)
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

  private

  def permit(params)
    params.require(:member).permit(:first_name, :last_name, :member_type, :date_of_birth, :email, :phone, :street, :zip, :city, :country)
  end
end
