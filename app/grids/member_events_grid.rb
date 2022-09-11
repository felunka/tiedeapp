class MemberEventsGrid < ApplicationGrid
  #
  # Scope
  #
  scope do
    Event.select('events.*, member_events.registration_id').joins(member_events: { member: :user })
  end

  def translation_model_name
    :event
  end

  #
  # Filters
  #
  filter(:name, :string)
  filter(:location, :string)

  #
  # Columns
  #
  column(:name)
  column(:location)
  column(:event_start) { |asset| I18n.l asset.event_start }
  column(:event_end) { |asset| I18n.l asset.event_end }
  column(:deadline_signup_in_words)

  column(:actions, html: true, header: '') do |asset|
    if asset.before_deadline_signup?
      if asset.registration_id
        button_to edit_registration_path(asset.registration_id), class: 'btn btn-primary btn-sm', method: :get do
          icon 'pen'
        end
      else
        button_to new_registration_path, class: 'btn btn-primary btn-sm', method: :get, params: { event_id: asset.id } do
          icon 'plus'
        end
      end
    end
  end
end
