module MembersHelper
  def update_relations(permitted_params)
    if permitted_params.has_key? :parents_marriage_attributes
      marriage = MemberMarriage.find_by(
        partner_1_id: permitted_params[:parents_marriage_attributes][:partner_1_id],
        partner_2_id: permitted_params[:parents_marriage_attributes][:partner_2_id]
      )
      marriage ||= MemberMarriage.create(
        partner_1_id: permitted_params[:parents_marriage_attributes][:partner_1_id],
        partner_2_id: permitted_params[:parents_marriage_attributes][:partner_2_id]
      )

      permitted_params[:parents_marriage_id] = marriage.id
      permitted_params.delete(:parents_marriage_attributes)

      Rails.cache.delete('tree_data')
    end

    # Handle marriages_attributes manually
    marriages_attributes = permitted_params.delete(:marriages_attributes)
    return unless marriages_attributes.present?

    marriages_attributes.each_value do |attrs|
      if ['true', true, '1', 1].include?(attrs[:_destroy])
        # Handle deletion if needed
        MemberMarriage.find(attrs[:id]).destroy if attrs[:id].present?
      else
        # Create or update marriage
        marriage = MemberMarriage.find_by(
          partner_1_id: attrs[:partner_1_id],
          partner_2_id: attrs[:partner_2_id]
        )
        marriage ||= MemberMarriage.create(
          partner_1_id: attrs[:partner_1_id],
          partner_2_id: attrs[:partner_2_id]
        )
      end
    end
    Rails.cache.delete('tree_data')
  end
end
