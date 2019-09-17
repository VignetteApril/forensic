require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class MainCase < ApplicationRecord
  include AASM

  # 虚拟字段用户接受关联的委托单参数
  belongs_to :department
  belongs_to :entrust_order, required: false 
  has_many :case_talks, dependent: :destroy
  has_many :express_orders, dependent: :destroy
  has_many :recive_express_orders, dependent: :destroy
  has_many :notification, dependent: :destroy
  has_many :case_users, dependent: :destroy # 机构中有很多
  has_many :transfer_docs, inverse_of: :main_case, dependent: :destroy # 机构中有很多【移交材料】
  has_many :case_process_records, dependent: :destroy # 案件中改变状态时的记录
  has_many :payment_orders, dependent: :destroy
  has_many :bills, dependent: :destroy
  has_many :refund_orders, dependent: :destroy
  has_many :case_memos, dependent: :destroy
  has_many :case_docs, class_name: 'DepartmentDoc',as: :docable, dependent: :destroy
  accepts_nested_attributes_for :transfer_docs, reject_if: :all_blank, allow_destroy: true
  has_one :appraised_unit, inverse_of: :main_case, dependent: :destroy # 机构中有一个【被鉴定人】
  accepts_nested_attributes_for :appraised_unit, reject_if: :all_blank, allow_destroy: true
  has_one_attached :barcode_image
  has_many_attached :entrust_docs # 案件下的委托书

  validates :matter, presence: { message: '不能为空' }
  validates :province_id, :city_id, :district_id, presence: true

  # 将科室内部的所有文档都拷贝到当前的案件下
  after_create :create_case_docs
  # 设置流水号
  before_create :set_serial_no
  # 设置委托单的状态为已认领
  after_save :set_entrust_order_status

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

  CASE_STAGE_COLOR_MAP = {
    pending: '#7143B4',
    add_material: '#ee5f5b',
    filed: '#22B8DD',
    rejected: '#524A47',
    executing: '#48DD22',
    executed: '#2B8514',
    apply_filing: '#DEEF98',
    close: '#EFAA98'  
  }

  CASE_BACKGROUND_COLOR = {
    filed: '#d5fccb',
    pending: '#cbd3fc',
    apply_filing: '#fcf0cb'
  }

  FINANCIAL_STAGE_MAP = {
    unpaid: '未支付',
    not_fully_paid: '未完全支付',
    paid: '已支付',
    refunded: '已退款'
  }

  def stage_color
    MainCase::CASE_STAGE_COLOR_MAP[self.case_stage.to_sym]
  end

  def case_background_color
    if self.is_delayed?
      '#fccbcb'
    else
      MainCase::CASE_BACKGROUND_COLOR[self.case_stage.to_sym]
    end
  end

  # 判断当前的案子是否延期
  # 能够延期的案子有两种情况
  # 1、当案件处于补充材料期，Time.now超过了created_at + 补充材料周期
  # 2、当案件处于其他阶段，Time.now超过了acceptance_date + identification_cycle.days
  # 这两个条件有一个过期就算过期
  # 如果两个周期的前提条件都没有，则直接判为不过期
  def is_delayed?
    if self.add_material?
      bool_first =  self.material_cycle.nil? ? false : Time.now > (self.created_at + self.material_cycle.days)
    else
      bool_second = self.identification_cycle.nil? ? false : Time.now > (self.acceptance_date + self.identification_cycle.days)
    end
    bool_first || bool_second
  end

  class << self
    def case_stage_collection
      rs = []
      case_stages.each do |key, value|
        rs << [CASE_STAGE_MAP[key.to_sym], key]
      end
      rs
    end

    def financial_stage_collection
      rs = []
      financial_stages.each do |key, value|
        rs << [FINANCIAL_STAGE_MAP[key.to_sym], key]
      end
      rs
    end

    # 返回当前user作为鉴定人的所有相关案件
    def ident_user_cases(user)
      cases = []
      self.all.each do |current_case|
        ident_users = current_case.ident_users
        cases << current_case if !ident_users.nil? && ident_users.split(',').include?(user.id.to_s)
      end
      cases
    end
  end

  aasm(:case, column: :case_stage, enum: true) do
    state :pending, initial: true
    state :add_material, :filed, :rejected, :executing, :executed, :apply_filing, :close
    after_all_transitions :record_case_process, :notify_user_case_stage_changed

    # 转换到 立案状态
    event :turn_filed, after: :update_filed_date do
      transitions from: MainCase.case_stages.keys.map(&:to_sym), to: :filed
    end

    # 转换到 结案
    event :turn_add_material do
      transitions from: MainCase.case_stages.keys.map(&:to_sym), to: :add_material
    end

    # 转换到 退案状态
    event :turn_rejected do
      transitions from: MainCase.case_stages.keys.map(&:to_sym), to: :rejected
    end

    # 转换到 执行中状态
    event :turn_executing do
      transitions from: MainCase.case_stages.keys.map(&:to_sym), to: :executing
    end

    # 转换到 执行完成状态
    event :turn_executed do
      transitions from: MainCase.case_stages.keys.map(&:to_sym), to: :executed
    end

    # 转换到 申请归档状态
    event :turn_apply_filing do
      transitions from: MainCase.case_stages.keys.map(&:to_sym), to: :apply_filing
    end

    # 转换到 结案状态
    event :turn_close do
      transitions from: MainCase.case_stages.keys.map(&:to_sym), to: :close
    end
  end

  aasm(:financial, column: :financial_stage, enum: true) do
    state :unpaid, initial: true
    state :not_fully_paid, :paid, :refunded
    after_all_transitions :notify_user_financial_stage_changed

    # 转换到 未支付状态
    event :turn_unpaid do
      transitions from: MainCase.financial_stages.keys.map(&:to_sym), to: :unpaid
    end

    # 转换到 未完全支付状态
    event :turn_not_fully_paid do
      transitions from: MainCase.financial_stages.keys.map(&:to_sym), to: :not_fully_paid
    end

    # 转换到 完全支付状态
    event :turn_paid do
      transitions from: MainCase.financial_stages.keys.map(&:to_sym), to: :paid
    end

    # 转换到 已退款状态
    event :turn_refunded do
      transitions from: MainCase.financial_stages.keys.map(&:to_sym), to: :refunded
    end
  end

  # 设置案件的顺序号
  def set_serial_no
    self.serial_no = Time.now.strftime('%Y%m%d%H%M%S%MS')
    barcode = Barby::Code128.new(self.serial_no)
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

  # 得到生成案号的方法
  # 只有没有case_no_display的案件才走总体的逻辑
  # 如果已经有了案号则不能重复生成
  def get_case_no
    center = self.department.organization
    dep_abbreviation = self.department.try(:abbreviation).blank? ? "" : self.department.try(:abbreviation)
    org_abbreviation = center.try(:abbreviation).blank? ? "" : center.try(:abbreviation)
    beginning_of_year = Date.today.beginning_of_year
    end_of_year = Date.today.end_of_year
    # 找到当前年份 当前科室 所有的case_no不为nil的案件 按照案件的编号排序
    main_cases = MainCase.where.not(id: self.id, case_no: nil).where(created_at: beginning_of_year..end_of_year, department_id: self.department.id ).order(:case_no)

    if main_cases.empty?
      self.case_no = self.department.case_start_no.nil? ? 1 : self.department.case_start_no
    else
      last_case =  main_cases.last
      self.case_no = last_case.case_no + 1
    end
    case_no_display = org_abbreviation + '司鉴' + "[#{Date.today.year}]" + dep_abbreviation + '鉴字第' + "#{self.case_no}" + '号'

    case_no_display
  end

  # 记录进程改变的信息
  def record_case_process
    self.case_process_records.create(detail: '案件进入' + CASE_STAGE_MAP[self.case_stage.to_sym] + '状态')
  rescue => ex
    Rails.logger.info ex.to_s
  end

  # 当案件的财务状态更改时通知鉴定人
  def notify_user_financial_stage_changed
    if !self.ident_users.nil?
      users = User.where(id: self.ident_users.split(','))
      users.each do |user|
        user.notifications.create( channel: :change_case_status,
                                   title: "案件#{self.serial_no}状态变更通知",
                                   description: "案件#{self.serial_no}于#{Time.now.strftime('%Y年%m月%d日%H时%M分')}变更为#{FINANCIAL_STAGE_MAP[self.financial_stage.to_sym]}状态",
                                   main_case_id: self.id, url: Rails.application.routes.url_helpers.payment_order_management_main_case_url(self, only_path: true))
      end
    end
  end

  # 当案件状态改变时，通知案件相关的鉴定人和委托人
  def notify_user_case_stage_changed
    # 通知到鉴定人
    ident_user_ids = self.ident_users.nil? ? [] : self.ident_users.split(',')
    # 通知到委托人
    user_ids = self.wtr_id.nil? ? ident_user_ids : ident_user_ids << self.wtr_id
    # 如果是申请归档的通知要通知到当前科室的档案管理员
    archivist_users = self.department.user_array
    archivist_users.each { |user| user_ids << user.id if user.center_archivist_user?  } if !archivist_users.empty?

    users = User.where(id: user_ids)
    # 发送通知
    users.each do |user|
      user.notifications.create( channel: :change_case_status,
                                 title: "案件#{self.serial_no}状态变更通知",
                                 description: "案件#{self.serial_no}于#{Time.now.strftime('%Y年%m月%d日%H时%M分')}变更为#{CASE_STAGE_MAP[self.case_stage.to_sym]}状态",
                                 main_case_id: self.id, url: Rails.application.routes.url_helpers.edit_main_case_url(self, only_path: true))
    end
  end

  # 当案件改变为立案阶段时更新立案日期
  def update_filed_date
    self.update(filed_date: Time.now)
  end

  # 从科室的模板中拷贝文档
  def create_case_docs
    if self.department.department_docs
      self.department.department_docs.each do |department_doc|
        # 将department doc中的信息复制到新创建的case doc中
        # 即便是没有文件要创建对应的实例作为占位
        case_doc = self.case_docs.create(department_doc.attributes.except('id', 'docable_id', 'docable_type', 'created_at', 'updated_at'))

        next unless department_doc.attachment.attached?
        # 将department doc中对应的文件复制到新创建的case doc中
        case_doc.attachment.attach io: StringIO.new(department_doc.attachment.download),
                                   filename: department_doc.attachment.filename,
                                   content_type: department_doc.attachment.content_type
        case_doc.update(filename: department_doc.attachment.filename)
      end
    end
  end

  # 更新相关联的委托单的状态为已认领
  def set_entrust_order_status
    if self.entrust_order
      self.entrust_order.claimed!
    end
  end

  # 判断当前user是否是案件的鉴定人
  def ident_user?(user)
    # TODO: 先打开所有的权限，等权限系统全部完成后再打开
    return true
    # self.ident_users.split(',').include?(user.id.to_s) if self.ident_users
  end

  # 暂时的ident_user?方法，因为ident_user控制着全局的js暂且用这个
  def temp_ident_user?(user)
    self.ident_users.split(',').include?(user.id.to_s) if self.ident_users
  end

  # 判断当前user是否是案件的委托人
  def wtr?(user)
    self.wtr_id == user.id
  end

  def decode_base64_image data_str
    content_type = data_str[/(image\/[a-z]{3,4})|(application\/[a-z]{3,4})/]
    content_type = content_type[/\b(?!.*\/).*/]
    contents = data_str.sub /data:((image|application)\/.{3,}),/, ''
    decoded_data = Base64.decode64(contents)
    filename = 'doc_' + Time.zone.now.to_s + '.' + content_type
    File.open("#{Rails.root}/tmp#{filename}", 'wb') do |f|
      f.write(decoded_data)
    end
    self.entrust_docs.attach(io: File.open("#{Rails.root}/tmp/#{filename}"), filename: filename)
    FileUtils.rm("#{Rails.root}/tmp/#{filename}")
  end
end
