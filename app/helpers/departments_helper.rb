# -*- encoding : utf-8 -*-
module DepartmentsHelper
  # 拼写部门层级链，用于显示当前部门所处的位置
  def department_chain(department)
    dc = []
    d = department
    while d.parent
      dc.push d.parent.name
      d = d.parent
    end
    return dc.reverse.join(' / ')
  end

  # 组合机构选择框的数据
  # 如果是admin的话则显示全部的数据，如果不是则只能选自己科室的数据
  # 而且只有组织机构类型为鉴定中心时才有科室的概念
  # 法院用户（委托人）是没有机构管理权限的
  def organization_collection
    organizations = admin? ? Organization.center : [@current_user.organization]
    organizations.map{ |organization| [organization.name, organization.id] }
  end
end
