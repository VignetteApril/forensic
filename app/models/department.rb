# 科室
class Department < ApplicationRecord
  validates :name, :presence => true, :length => {:maximum => 200}
  validates :code, :presence => true, :length => {:maximum => 20}
  validates :brief,                   :length => {:maximum => 100}
  validates :admin_level,             :length => {:maximum => 100}
  validates :role_type,               :length => {:maximum => 100}

  has_ancestry
  has_many :users
  belongs_to :organization

  # 是否是叶子节点
  def leaf?
    return self.is_childless?
  end

  # 拼写部门层级链，用于显示当前部门所处的位置
  def department_route
    dc = [self.name]
    d = self
    while d.parent
      dc.push d.parent.name
      d = d.parent
    end
    return dc.reverse.join(' / ')
  end
end
