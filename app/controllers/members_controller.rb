class MembersController < ApplicationController
  before_action :require_admin, only: [:new, :create, :destroy]
  skip_before_action :require_login, only: [:autocomplete]

  def index
    @show_hidden = params[:show_hidden]
    @members_grid = MembersGrid.new(params[:members_grid]) do |scope|
      if @show_hidden
        scope.page(params[:page])
      else
        scope.visible.page(params[:page])
      end
    end
  end

  def autocomplete
    # ensure user logged in OR valid token present
    raise ApplicationController::NotAuthorized unless current_user.present? || Event.joins(:member_events).where(member_events: { token: params.delete(:token), registration_id: nil }).any?

    @members = Member.visible.where("CONCAT_WS(' ', first_name, last_name) ILIKE ?", "%#{params[:term]}%").limit(10).map do |model|
      { id: model.id, text: model.full_name_and_status }
    end

    respond_to do |format|
      format.json { render json: @members }
    end 
  end

  def new
    @member = Member.new
    @member.parents_marriage = MemberMarriage.new
  end

  def create
    @member = Member.new permit(params)

    respond_to do |format|
      if @member.save
        flash[:success] = t('messages.model.created')
        format.html { redirect_to action: 'index' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    raise ApplicationController::NotAuthorized unless current_user.admin? || current_user.member.id == params[:id].to_i

    @member = Member.find_by params.permit(:id)
    @member.parents_marriage = MemberMarriage.new unless @member.parents_marriage
  end

  def update
    raise ApplicationController::NotAuthorized unless current_user.admin? || current_user.member.id == params[:id].to_i

    @member = Member.find_by params.permit(:id)
    respond_to do |format|
      ActiveRecord::Base.transaction do
        permitted_params = permit(params)
        if permitted_params.has_key? :parents_marriage_attributes
          marriage = MemberMarriage.find_by(
            partner_1_id: permitted_params[:parents_marriage_attributes][:partner_1_id],
            partner_2_id: permitted_params[:parents_marriage_attributes][:partner_2_id]
          )
          unless marriage
            marriage = MemberMarriage.create(
              partner_1_id: permitted_params[:parents_marriage_attributes][:partner_1_id],
              partner_2_id: permitted_params[:parents_marriage_attributes][:partner_2_id]
            )
          end

          permitted_params[:parents_marriage_id] = marriage.id
          permitted_params.delete(:parents_marriage_attributes)

          Rails.cache.delete("tree_data")
        end
        if @member.update permitted_params
          # Clean up stale marriages
          MemberMarriage.where.missing(:members).destroy_all
          flash[:success] = t('messages.model.updated')
          format.html { redirect_to action: 'index' }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    Member.find_by(params.permit(:id)).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to action: 'index'
  end

  private

  def permit(params)
    if current_user.admin?
      params.require(:member).permit(
        :first_name,
        :last_name,
        :member_type,
        :date_of_birth,
        :date_of_death,
        :email,
        :phone,
        :street,
        :zip,
        :city,
        :country,
        :hidden,
        parents_marriage_attributes: [
          :id,
          :partner_1_id,
          :partner_2_id
        ]
      )
    else
      params.require(:member).permit(:first_name, :last_name, :date_of_birth, :email, :phone, :street, :zip, :city, :country)
    end
  end
end
