class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:landing, :new, :create]

  def landing
    redirect_to member_events_path if current_user
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
