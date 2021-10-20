class ApplicationController < ActionController::Base
  before_action :require_login

  helper_method :logged_in

  private

  def logged_in
    session[:logged_in]
  end

  def require_login
    unless logged_in
      redirect_to new_session_path
    end
  end
end
