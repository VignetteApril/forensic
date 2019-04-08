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
end
