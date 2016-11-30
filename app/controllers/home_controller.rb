class HomeController < ApplicationController

  def home
    if (current_user && current_user.role?(:student))
      @recommended_orgs = find_organization_recommendations
      @student = current_user.student.id

    elsif (current_user)
    #  @recommended_houses = find_house_recommendations
    else
      redirect_to login_path
    end
  end

  def about
  end

  def privacy
  end

  def contact
  end

  def student_dashboard
    @positions = get_positions
    @commitments = find_commitments
  end

  private

  def get_positions
    commitments = current_user.student.commitments
    positions = Array.new

    commitments.each do |c|
      positions << Position.get_position_from_org_id(c.organization_id).map{|p| [p.name, p.hour_commitment, p.description]}
    end

    return positions
  end

  def find_organization_recommendations
    tag_ids = match_interests_to_tags
    org_ids = match_tags_to_orgs(tag_ids)
    matching_orgs = find_org_names(org_ids)

    return matching_orgs
  end

  def find_commitments
    commitments = current_user.student.commitments
    matching_orgs = Array.new

    commitments.each do |c|
      matching_orgs << Organization.for_org(c.organization_id).map{|o| [o.id, o.name, o.description]}
    end

    return matching_orgs
  end

  def match_interests_to_tags
    interests = current_user.student.interests
    matching_tags = Array.new

    interests.each do |i|
      matching_tags << Tag.for_interest(i.name).map(&:id)  
    end

    return matching_tags

  end

  def match_tags_to_orgs(tag_ids)
    matching_orgs = Array.new

    tag_ids.each do |t|
      matching_orgs << OrgTag.for_org(t).map(&:organization_id)
    end

    return matching_orgs
  end

  def find_org_names(org_ids)
    matching_orgs = Array.new

    org_ids.each do |oi|
      matching_orgs << Organization.for_org(oi).map {|o| [o.id, o.name, o.description]}
    end

    return matching_orgs
  end


end