class Bill < ApplicationRecord
	belongs_to :main_case
	has_many :payment_orders

  # 默认状态为未开
  enum bill_stage: [ :unBilled, :billed, :taked_away ]
  BILL_STAGE_MAP = { unBilled: '未开', billed: '已开', taked_away: '已领走' }

  # 发票类型
  enum bill_type: [ :vat_ordinary, :vat_special ]
  BILL_TYPE_MAP = { vat_ordinary: '增值税普通发票', vat_special: '增值税专用发票'  }

  before_destroy :update_payment_orders

  # 当用户删除某一个发票时需要更新所有的缴费单的中bill_id字段为空
  def update_payment_orders
    self.payment_orders.update_all(bill_id: nil)
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