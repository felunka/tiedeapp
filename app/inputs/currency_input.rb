class CurrencyInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options)
    currency_prefix = content_tag(:span, content_tag(:i, '', class: 'fas fa-euro-sign'), class: 'input-group-text')

    template.content_tag :div, class: 'input-group' do
      currency_prefix +
      super
    end
  end
end
