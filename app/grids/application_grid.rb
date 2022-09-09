class ApplicationGrid
  include Datagrid


  def self.actions(available_actions = [:show, :edit, :destroy])
    column(:actions, html: true) do |asset|
      content_tag(:div, class: 'd-flex model-buttons') do
        if available_actions.include? :show
          concat(
            button_to(send("#{asset.model_name.singular}_path", asset), class: 'btn btn-primary btn-sm', method: :get) do
              icon 'search'
            end
          )
        end
        if available_actions.include? :edit
          concat(
            button_to(send("edit_#{asset.model_name.singular}_path", asset), class: 'btn btn-primary btn-sm', method: :get)do
              icon 'pen'
            end
          )
        end
        if available_actions.include? :destroy
          concat(
            button_to(send("#{asset.model_name.singular}_path", asset), class: 'btn btn-danger btn-sm', method: :delete, form: { data: { turbo_confirm: t('helpers.submit.confirm') } } )do
              icon 'trash'
            end
          )
        end
      end
    end
  end
end