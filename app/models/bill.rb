class Bill < ApplicationRecord
  attr_accessor :data_str

	belongs_to :main_case
	has_many :payment_orders
  has_one_attached :attachment

  # 默认状态为未开
  enum bill_stage: [ :unBilled, :billed, :taked_away ]
  BILL_STAGE_MAP = { unBilled: '未开票', billed: '已开票', taked_away: '已领走' }

  # 发票类型
  enum bill_type: [ :vat_ordinary, :vat_special ]
  BILL_TYPE_MAP = { vat_ordinary: '增值税普通发票', vat_special: '增值税专用发票'  }

  before_destroy :update_payment_orders
  after_create :notify_finance_user

  # 当用户删除某一个发票时需要更新所有的缴费单的中bill_id字段为空
  def update_payment_orders
    self.payment_orders.update_all(bill_id: nil)
  end

  # 通知当前机构下的财务用户去修改发票的信息
  def notify_finance_user
    current_department = self.main_case.department
    current_org = current_department.organization if current_department
    users = current_org.users if current_org
    users.each do |user|
      next if !user.center_finance_user?
      user.notifications.create( channel: :apply_bill,
                                 title: "发票单提交申请",
                                 description: "发票#{self.id}于#{Time.now.strftime('%Y年%m月%d日%H时%M分')}已经创建，请知悉",
                                 main_case_id: self.main_case.id, url: Rails.application.routes.url_helpers.finance_index_main_case_bills_path(-1))
    end
  end

  def decode_base64_image data_str
    content_type = data_str[/(image\/[a-z]{3,4})|(application\/[a-z]{3,4})/]
    content_type = content_type[/\b(?!.*\/).*/]
    contents = data_str.sub /data:((image|application)\/.{3,}),/, ''
    decoded_data = Base64.decode64(contents)
    filename = 'doc_' + Time.zone.now.to_s + '.' + content_type
    File.open("#{Rails.root}/tmp/#{filename}", 'wb') do |f|
      f.write(decoded_data)
    end
    self.attachment.attach(io: File.open("#{Rails.root}/tmp/#{filename}"), filename: filename)
    FileUtils.rm("#{Rails.root}/tmp/#{filename}")
  end

  class << self
    def bill_type_collection
      rs = []
      bill_types.each do |key, value|
        rs << [BILL_TYPE_MAP[key.to_sym], key]
      end
      rs
    end

  end
end