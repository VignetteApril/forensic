require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'


class MainCase < ApplicationRecord
  include AASM

  belongs_to :department
  has_many :case_talks
  has_many :case_users, dependent: :destroy # 机构中有很多
  has_many :transfer_docs, inverse_of: :main_case, dependent: :destroy # 机构中有很多【移交材料】
  has_many :case_process_records # 案件中改变状态时的记录
  has_many :case_docs, class_name: 'DepartmentDoc',as: :docable
  accepts_nested_attributes_for :transfer_docs, reject_if: :all_blank, allow_destroy: true
  has_one :appraised_unit, inverse_of: :main_case, dependent: :destroy # 机构中有一个【被鉴定人】
  accepts_nested_attributes_for :appraised_unit, reject_if: :all_blank, allow_destroy: true
  has_many :payment_orders
  accepts_nested_attributes_for :payment_orders, reject_if: :all_blank, allow_destroy: true
  has_one_attached :barcode_image

  validates :matter, presence: { message: '不能为空' }

  # 将科室内部的所有文档都拷贝到当前的案件下
  after_create :create_case_docs

  # 设置流水号
  before_create :set_serial_no

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
    state :add_material, :filed, :rejected, :executing, :executed, :apply_filing, :close

    # 立案动作，可以从状态 待立案 和 待补充材料 和 退案 转换到 立案状态
    event :turn_filed, after: :record_case_process do
      transitions from: [:pending, :add_material, :rejected, :filed], to: :filed
    end

    # 把案件状态变为 待补充材料，可以从立案，待立案，结案转换
    event :turn_add_material, after: :record_case_process do
      transitions from: [:filed, :pending, :rejected, :add_material], to: :add_material
    end

    # 结案动作，可以从状态 立案 和 待立案 和 待补充材料 转换到 退案状态
    event :turn_rejected, after: :record_case_process do
      transitions from: [:filed, :pending, :add_material, :rejected], to: :rejected
    end
  end

  aasm(:financial, column: :financial_stage, enum: true) do
    state :unpaid, initial: true
    state :not_fully_paid, :paid, :refunded
  end

  # 设置案件的顺序号
  def set_serial_no
    self.serial_no = Time.now.strftime('%Y%m%d%H%M%S')

    barcode = Barby::Code128B.new(self.serial_no)
    blob = Barby::PngOutputter.new(barcode).to_png
    self.barcode_image.attach io: StringIO.new(blob),
                              filename: self.serial_no + '.png',
                              content_type: 'image/png'
  end

  # 鉴定中心简称 + '司鉴' + [年度] + '鉴字第' + 科室内部编号 + '号'
  def set_case_no
    self.case_no_display = get_case_no
    self.save!
  end

  def get_case_no
    center = self.department.organization
    dep_abbreviation = self.department.abbreviation
    org_abbreviation = center.abbreviation
    beginning_of_year = Date.today.beginning_of_year
    end_of_year = Date.today.end_of_year
    # 找到当前年份 当前科室 所有的案件 按照案件的编号排序
    main_cases = MainCase.where.not(id: self.id).where(created_at: beginning_of_year..end_of_year, department_id: self.department.id ).order(:case_no)
    if main_cases.empty?
      self.case_no = self.department.case_start_no.nil? ? 1 : self.department.case_start_no
    else
      last_case =  main_cases.last
      self.case_no = last_case.case_no + 1
    end
    case_no_display = org_abbreviation + '司鉴' + "[#{Date.today.year}]" + dep_abbreviation + '鉴字第' + "#{self.case_no}" + '号'

    case_no_display
  end

  # 记录案件状态改变的信息
  def record_case_process
    self.case_process_records.create(detail: '案件进入' + CASE_STAGE_MAP[self.case_stage.to_sym] + '状态')
  end

  # 从科室的模板中拷贝文档
  def create_case_docs
    if self.department.department_docs
      self.department.department_docs.each do |department_doc|
        # 将department doc中的信息复制到新创建的case doc中
        case_doc = self.case_docs.create(department_doc.attributes.except('id', 'docable_id', 'docable_type'))

        # 将department doc中对应的文件复制到新创建的case doc中
        case_doc.attachment.attach io: StringIO.new(department_doc.attachment.download),
                                          filename: department_doc.attachment.filename,
                                          content_type: department_doc.attachment.content_type
        case_doc.update(filename: department_doc.attachment.filename)
      end
    end
  end
end
