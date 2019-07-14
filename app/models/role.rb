# -*- encoding : utf-8 -*-
class Role < ApplicationRecord
  validates :name, :presence => true

  has_many :user_roles, dependent: :delete_all
  has_many :users, :through => :user_roles
  has_many :role_features, dependent: :delete_all
  has_many :features, through: :role_features

  # 系统的角色分为 法院、鉴定中心角色、平台角色
  # 角色的分类由平台管理员决定
  enum r_type: [ :court, :center, :platform ]

  ROLE_TYPE_MAP = { court: '法院',
                    center: '鉴定中心',
                    platform: '平台'}

  # 定死角色的名称，系会根据角色区分
  enum name: [ :admin_user,
               :client_entrust_user,
               :center_admin_user,
               :center_director_user,
               :center_department_director_user,
               :center_filing_user,
               :center_ident_user,
               :center_assistant_user,
               :center_archivist_user,
               :center_finance_user ]

  NAME_TYPE = { admin_user: '系统管理员',
                client_entrust_user: '委托人',
                center_admin_user: '鉴定中心管理员',
                center_director_user: '鉴定中心主任',
                center_department_director_user: '鉴定中心科室主任',
                center_filing_user: '鉴定中心立案人员',
                center_ident_user: '鉴定中心鉴定人',
                center_assistant_user: '鉴定中心助理',
                center_archivist_user: '鉴定中心档案管理员',
                center_finance_user: '鉴定中心财务人员'  }

  # 因为name字段改为了enum，所以为每个role实例加了name_human方法来展示角色名称
  def name_human
    NAME_TYPE[self.name.to_sym]
  end

  class << self
    # 为前端的显示的方法
    def collection_select_arr
      rs = []
      r_types.each do |key, value|
        rs << [ROLE_TYPE_MAP[key.to_sym], key]
      end
      rs
    end
  end
end
