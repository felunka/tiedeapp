class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @token = params[:token]
    unless @token.present?
      flash[:danger] = t('model.user.error.only_with_token')
      redirect_to root_path
      return
    end
    @member = Member.joins(:member_events).where(member_events: { token: @token }).first
    unless @member.present?
      flash[:danger] = t('model.user.error.token_invalid')
      redirect_to root_path
    end
  end

  def create
    respond_to do |format|
      # First check if token is valid
      if Member.joins(:member_events).where(id: params[:user][:member_id], member_events: { token: params[:user].delete(:token) })
        # Check if user already exsist
        if User.find_by(member_id: params[:user][:member_id])
          flash[:danger] = t('model.user.error.user_exists')
          format.html { redirect_to new_session_path }
        else
          # Check if email was supplied => update member
          if email = params[:user].delete(:email)
            Member.find(params[:user][:member_id]).update email: email
          end
          # Create user and log him in
          user = User.create params.require(:user).permit(:member_id, :password, :password_confirmation)
          session[:user_id] = user.id
          flash[:success] = t('messages.model.created')
          format.html { redirect_to root_path }
        end
      else
        flash[:danger] = t('model.user.error.token_invalid')
        format.html { redirect_to root_path }
      end
    end
  end
end
