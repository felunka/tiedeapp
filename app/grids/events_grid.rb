class EventsGrid < ApplicationGrid
  #
  # Scope
  #
  scope do
    Event.all
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

  actions
end
