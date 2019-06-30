class IncomingRecord < ApplicationRecord
  belongs_to :payment_order, required: false # 每一个到账记录都属于一个缴费单
  belongs_to :organization

  enum status: [:unclaimed, :claimed]
  STATUS_MAP = { unclaimed: '未认领',
                 claimed: '已认领'}

  enum pay_type: [:check, :cash]
  PAY_TYPE_MAP = { check: '支票',
                   cash: '现金' }

  class << self
    def status_select_arr
      rs = []
      status.each do |key, value|
        rs << [STATUS_MAP[key.to_sym], key]
      end
      rs
    end

    def pay_type_select_arr
      rs = []
      pay_types.each do |key, value|
        rs << [PAY_TYPE_MAP[key.to_sym], key]
      end
      rs
    end
  end
end
