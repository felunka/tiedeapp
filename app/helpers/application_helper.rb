module ApplicationHelper
  def nav_item(name, path, admin = false)
    return if current_user.nil?
    return if admin && !current_user.admin?
    content_tag :li, class: "nav-item #{'active' if current_page?(path)}" do
      link_to name, path, class: 'nav-link'
    end
  end
end
