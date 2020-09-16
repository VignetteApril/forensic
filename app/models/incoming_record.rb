# == Schema Information
#
# Table name: incoming_records
#
#  id               :bigint           not null, primary key
#  status           :integer          default("unclaimed")
#  pay_account      :string
#  pay_person_name  :string
#  amount           :float
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pay_date         :datetime
#  pay_type         :integer
#  payment_order_id :bigint
#  organization_id  :bigint
#  check_num        :string
#  remarks          :string
#  claim_user_id    :integer
#
class IncomingRecord < ApplicationRecord
  belongs_to :payment_order, required: false # 每一个到账记录都属于一个缴费单
  belongs_to :organization

  enum status: [:unclaimed, :claimed]
  STATUS_MAP = { unclaimed: '未认领',
                 claimed: '已认领'}

  enum pay_type: [:check, :cash, :remit, :wechat, :card]
  PAY_TYPE_MAP = { check: '支票',
                   cash: '现金',
                   remit: '汇款',
                   wechat: '微信',
                   card: '刷卡' }

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
