class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:landing, :new, :create]

  def landing
    if current_user
      redirect_to member_events_path
      return
    end
    unless params[:token].present?
      redirect_to new_session_path
      return
    end
    @token = params[:token]
  end

  def new
    @token = params[:token]
  end

  def create
    user = Member.find_by(params.require(:user).permit(:email))&.user

    respond_to do |format|
      if user && user.authenticate(params.require(:user)[:password])
        reset_session
        session[:user_id] = user.id
        flash[:success] = t('messages.login.success')
        format.html { redirect_to member_events_path }
      else
        flash[:danger] = t('messages.login.fail')
        format.html { redirect_to action: 'new', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    reset_session

    redirect_to action: 'new'
  end
end
