class UsersController < ApplicationController
  def new
    @token = params[:token]
    @member = Member.joins(:member_events).where(member_events: { token: @token }).first
  end

  def create
    # First check if token is valid
    if Member.joins(:member_events).where(id: params[:user][:member_id], member_events: { token: params[:user].delete(:token) })
      # Check if user already exsist
      if User.find_by(member_id: params[:user][:member_id])
        flash[:danger] = t('user.error.user_exists')
        redirect_to new_session_path
      else
        # Create user and log him in
        user = User.create params.require(:user).permit(:member_id, :password, :password_confirmation)
        session[:user_id] = user.id
        flash[:success] = t('messages.model.created')
        redirect_to root_path
      end
    else
      flash[:danger] = t('user.error.token_invalid')
      redirect_to new_session_path
    end
  end
end
