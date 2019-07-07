# 机构组织
class Organization < ApplicationRecord
  attr_accessor :organization_id,:is_new_org
  belongs_to :area
  has_many :entrust_orders, dependent: :destroy # 每个鉴定中心下有很多委托单，有的还未创建maincase
  has_many :departments, dependent: :destroy # 每个机构有很多科室，当机构删除时，科室理应被删除
  has_many :main_cases, through: :departments # 机构通过部门获取到案件信息
  has_many :payment_orders, through: :main_cases
  has_many :bills, through: :main_cases
  has_many :users, dependent: :destroy      # 每个机构中有很多个用户，当机构被删除时，用户理应被删除
  has_many :identification_cycles, dependent: :destroy # 每个机构中很有多个鉴定周期，当机构被删除时，则鉴定周期也无意义
  has_many :material_cycles, dependent: :destroy # 每个机构中有很多个补充材料周期
  has_many :incoming_records, dependent: :destroy #每个机构中有很多个到账记录

  validates :name, uniqueness: true, presence: true  #机构名称唯一，必填
  validates :abbreviation, presence: { message: '不能为空' }, unless: :is_court?
  validates :org_type, presence: { message: '不能为空' }
  validates :payee, :open_account_bank, :account_number, presence: { message: '不能为空' }, unless: :is_court?

  def is_court?
    self.org_type == 'court'
  end

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
