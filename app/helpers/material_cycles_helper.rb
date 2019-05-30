module MaterialCyclesHelper
  def organization_collection
    organizations = admin? ? Organization.center : [@current_user.organization]
    organizations.map{ |organization| [organization.name, organization.id] }
  end
end
