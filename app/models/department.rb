class Department < ActiveRecord::Base
  validates :name, :presence => true, :length => {:maximum => 200}
  validates :code, :presence => true, :length => {:maximum => 20}
  validates :brief,                   :length => {:maximum => 100}
  validates :admin_level,             :length => {:maximum => 100}
  validates :role_type,               :length => {:maximum => 100}

  # has_closure_tree dependent: :destroy, order: :sort_no
  has_ancestry # :ancestry_column => "parent_id"

  # has_many :user_departments, dependent: :delete_all
  has_many :users # , :through => :user_departments

  # include SLicense
  # validate :verify_node_count

  # 核实节点数量是否符合授权
  # def verify_node_count
  #   if self.is_root?
  #     if Department.roots.size > 0
  #       errors.add(:name, "您最多能够创建1个根节点")
  #     end
  #     return
  #   end

  #   a1 = license_array.map{ |c| c.split(':') }.select{ |c| c[0]=='level1_org_max' }
  #   a2 = license_array.map{ |c| c.split(':') }.select{ |c| c[0]=='level2_org_max' }
  #   if a1.empty? or a1[0][1].blank?
  #     level1_org_max = 1
  #   else
  #     level1_org_max = a1[0][1].to_i
  #   end
  #   if a2.empty? or a2[0][1].blank?
  #     level2_org_max = 0
  #   else
  #     level2_org_max = a2[0][1].to_i
  #   end

  #   level1_org_cur = self.root.children.select{ |n| n.has_children? }.size
  #   level1_org_cur += 1 if self.parent.depth == 1 and !self.parent.has_children?
  #   level2_org_cur = self.root.descendants.select{ |n| n.depth == 2 and n.has_children? }.size
  #   level2_org_cur += 1 if self.parent.depth == 2 and !self.parent.has_children?

  #   if level1_org_cur > level1_org_max
  #     errors.add(:name, "您最多能够创建#{level1_org_max}个一级组织节点")
  #   end
  #   if level2_org_cur > level2_org_max
  #     errors.add(:name, "您最多能够创建#{level2_org_max}个二级组织节点")
  #   end
  # end

  # 是否是叶子节点
  def leaf?
    return self.is_childless?
  end

  # 所有节点排序组织
  def Department.roots_and_descendants_preordered
    Department.sort_by_ancestry(Department.all)
  end

  # 获取一个部门节点下所有子节点的格式化字符串数组（按树状结构缩进）
  # def Department.get_select_arr(parent_id = 0)
  #   if parent_id == 0 || parent_id.blank?
  #     @select_arr = []
  #   end
  #   self.where(parent_id: parent_id).order(:sort_no).each do |d|
  #     @select_arr << [ "#{'&nbsp;' * d.depth.to_i * 4}#{d.name}", d.id ]
  #     if !d.leaf?
  #       get_select_arr(d.id)
  #     end
  #   end
  #   @select_arr
  # end

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
