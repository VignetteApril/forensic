class MainCase < ApplicationRecord
  include AASM

  # attr_accessor :province_id, :city_id, :district_id

  belongs_to :department
  has_many :case_users, dependent: :destroy # 机构中有很多
  has_many :transfer_docs, inverse_of: :main_case, dependent: :destroy # 机构中有很多
  accepts_nested_attributes_for :transfer_docs, reject_if: :all_blank, allow_destroy: true
  has_one :appraised_unit, inverse_of: :main_case, dependent: :destroy # 机构中有很多
  accepts_nested_attributes_for :appraised_unit, reject_if: :all_blank, allow_destroy: true

  # 案件状态：待立案、待补充材料、立案、退案、执行中、执行完成、申请归档、结案
  # 财务状态：未付款、未付清、已付清、已退款
  enum case_stage: [ :pending, :add_material, :filed, :rejected, :executing, :executed, :apply_filing, :close ]
  enum financial_stage: [:unpaid, :not_fully_paid, :paid, :refunded]
  CASE_STAGE_MAP = {
      pending: '待立案',
      add_material: '待补充材料',
      filed: '立案',
      rejected: '退案',
      executing: '执行中',
      executed: '执行完成',
      apply_filing: '申请归档',
      close: '结案'
  }

  FINANCIAL_STAGE_MAP = {
      unpaid: '未支付',
      not_fully_paid: '未完全支付',
      paid: '已支付',
      refunded: '已退款'
  }

  aasm(:case, column: :case_stage, enum: true) do
    state :pending, initial: true
    state :add_material, :add_material, :filed, :rejected, :executing, :executed, :apply_filing, :close
  end

  aasm(:financial, column: :financial_stage, enum: true) do
    state :unpaid, initial: true
    state :not_fully_paid, :paid, :refunded
  end

  # callbacks
  # 设置流水号
  before_create :set_serial_no
  # 设置案件编号
  # before_create :set_case_no
  # 把科室的模板文件复制到当前的案件中
  after_save :create_case_docs

  validates :matter, presence: { message: '不能为空' }


  def set_serial_no
    self.serial_no = Time.now.strftime('%Y%m%d%H%M%S')
  end

  # 鉴定中心简称 + '司鉴' + [年度] + '鉴字第' + 科室内部编号 + '号'
  def set_case_no
    center = self.department.organization
    dep_abbreviation = self.department.abbreviation
    org_abbreviation = center.abbreviation
    beginning_of_year = Date.today.beginning_of_year
    end_of_year = Date.today.end_of_year
    # 找到当前年份 当前科室 所有的案件 按照案件的编号排序
    main_cases = MainCase.where.not(id: self.id).where(created_at: beginning_of_year..end_of_year, department_id: self.department.id ).order(:case_no)
    if main_cases.empty?
      self.case_no = 1
    else
      last_case =  main_cases.last
      self.case_no = last_case.case_no + 1
    end
    self.case_no_display = org_abbreviation + '司鉴' + "#{Date.today.year}" + dep_abbreviation + '鉴字第' + "#{self.case_no}" + '号'
    self.save!
  end

  def create_case_docs
    
  end
end
