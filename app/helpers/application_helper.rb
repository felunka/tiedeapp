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
end
