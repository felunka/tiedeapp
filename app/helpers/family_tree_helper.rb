module FamilyTreeHelper

  def render_tree_data(member)
    result = {
      id: member.id,
      name: member.full_name,
      date_of_birth: format_date(member.date_of_birth),
      date_of_death: format_date(member.date_of_death),
      marriages: []
    }

    member.member_marriages_as_partner_1.each do |marriage|
      marriage_result = {
        spouse: {
          id: marriage.partner_2.id,
          name: marriage.partner_2.full_name,
          date_of_birth: format_date(marriage.partner_2.date_of_birth),
          date_of_death: format_date(marriage.partner_2.date_of_death),
        },
        children: []
      }

      Member.where(parents_marriage: marriage).each do |child|
        marriage_result[:children] << render_tree_data(child)
      end

      result[:marriages] << marriage_result
    end

    result
  end

  def process_member(member_data, parents_marriage=nil)
    unless member = Member.find_by(id: member_data[:id])
      member = Member.new
      member.first_name = member_data[:name]
      member.last_name = ""
      member.hidden = true
      member.skip_invite = true
    end

    unless parents_marriage.nil?
      member.parents_marriage = parents_marriage
    end

    member.date_of_birth ||= member_data[:birthDate]
    member.date_of_death ||= member_data[:deathDate]
    member.save!

    member_data[:marriages].each do |marriage|
      unless spouse = Member.find_by(id: marriage[:spouse][:id])
        spouse = Member.new
        spouse.first_name = marriage[:spouse][:name]
        spouse.last_name = ""
        spouse.hidden = true
        spouse.skip_invite = true
      end
  
      spouse.date_of_birth ||= marriage[:spouse][:birthDate]
      spouse.date_of_death ||= marriage[:spouse][:deathDate]
      spouse.save!

      marriage_relation = MemberMarriage.new(partner_1: member, partner_2: spouse)
      marriage_relation.save!

      marriage[:children].each do |child|
        process_member(child, marriage_relation)
      end
    end
  end

  def format_date(date)
    return I18n.l(date) unless date.nil?
    return ""
  end
  
end