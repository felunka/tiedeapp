module ApplicationHelper
  def nav_item(name, path, admin = false)
    return if current_user.nil?
    return if admin && !current_user.admin?
    content_tag :li, class: "nav-item #{'active' if current_page?(path)}" do
      link_to name, path, class: 'nav-link'
    end
  end

  def bool_to_icon(value)
    if value
      content_tag :i, '', class: 'fa fa-check'
    else
      content_tag :i, '', class: 'fa fa-times'
    end
  end

  def icon(name, classes = [])
    tag_classes = ['fa-solid', "fa-#{name}"] + classes
    content_tag :i, nil, class: tag_classes
  end

  def icon_stack(names)
    content_tag :span, class: 'fa-stack' do
      names.each_with_index.map do |name, index|
        concat icon(name, ["fa-stack-#{index+1}x"])
      end
    end
  end

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def generate_qr_code(token)
    target_url = CGI.escape(root_url(token: token))
    return "https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl=#{target_url}&choe=UTF-8"
  end
end
