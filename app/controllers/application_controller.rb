class ApplicationController < ActionController::Base
  before_action :require_login

  helper_method :current_user

  NotAuthorized = Class.new(StandardError)

  def current_user
    return nil unless session[:user_id]
    @current_user ||= User.find session[:user_id]
  end

  def require_login
    unless current_user
      redirect_to root_path
    end
  end

  def require_admin
    if current_user.nil? || !current_user.admin?
      redirect_to root_path
    end
  end

  rescue_from ApplicationController::NotAuthorized do |exception|
    respond_to do |format|
      format.any  { head 403 }
    end
  end
end
