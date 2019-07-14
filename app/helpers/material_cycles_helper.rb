module MaterialCyclesHelper
  def organization_collection
    organizations = @current_user.admin? ? Organization.center : [@current_user.organization]
    organizations.map{ |organization| [organization.name, organization.id] }
  end
end
