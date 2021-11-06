class SessionsController < ApplicationController
  def landing
    redirect_to member_events_path if current_user
    @token = params[:token]
  end

  def new
    @token = params[:token]
  end

  def create
    user = Member.find_by(params.require(:user).permit(:email)).user

    if user && user.authenticate(params.require(:user)[:password])
      session[:user_id] = user.id
      flash[:success] = 'Login erfolgreich'
      redirect_to member_events_path
    else
      flash[:danger] = 'Login fehlgeschlagen'
      redirect_to action: 'new'
    end
  end

  def destroy
    session[:user_id] = nil

    redirect_to action: 'new'
  end
end
