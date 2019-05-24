# 机构组织
class Organization < ApplicationRecord
  belongs_to :area
  has_many :departments, dependent: :destroy # 每个机构有很多科室，当机构删除时，科室理应被删除
  has_many :users, dependent: :destroy      # 每个机构中有很多个用户，当机构被删除时，用户理应被删除

  validates :abbreviation, presence: { message: '不能为空' }


  # 组织类型对照表
  ORG_TYPE_MAP = { court: '法院',
                   center: '鉴定中心'}
  enum org_type: [:court, :center]

  class << self
    # 为前端的显示的方法
    def collection_select_arr
      rs = []
      org_types.each do |key, value|
        rs << [ORG_TYPE_MAP[key.to_sym], key]
      end
      rs
    end
  end
end
