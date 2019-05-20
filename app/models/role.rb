# -*- encoding : utf-8 -*-
class Role < ApplicationRecord
  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 50}
  validates :r_type, :presence => true

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
