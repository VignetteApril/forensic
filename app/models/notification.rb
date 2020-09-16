# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: notifications
#
#  id           :bigint           not null, primary key
#  title        :string
#  url          :string
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  channel      :integer
#  status       :boolean          default(FALSE)
#  description  :text
#  main_case_id :bigint
#
class Notification < ApplicationRecord
    belongs_to :user
    belongs_to :main_case

    enum channel: [ :recived_order,
					          :filed,
                    :create_case,
                    :change_case_status,
                    :apply_filing,
                    :case_online_pay,
                    :apply_bill,
                    :bill_made,
                    :add_case_tip,
                    :submit_payment_order,
                    :submit_refund_order,
                    :confirm_payment_order,
                    :confirm_refund_order ]

    CHANNEL_MAP = {
      :recived_order=>'收到委托单',
      :filed=>'立案',
      :create_case=>'创建案件',
      :change_case_status=>'案件状态变更',
      :apply_filing=>'申请归档',
      :case_online_pay=>'案件在线付款',
      :apply_bill=>'申请发票',
      :bill_made=>'发票已开',
      :add_case_tip=>'案件新增便签',
      :submit_payment_order => '提交缴费单',
      :submit_refund_order => '提交退费单',
      :confirm_payment_order => '确认缴费单',
      :confirm_refund_order => '确认退费单'
    }

    def infos_for_api
    	{
        "id":self.id,
        "case_id":self.main_case.try(:id),
    		"titie": self.title,
    		"description":self.description,
    		"status": self.status ,
    		"created_at": self.created_at.strftime('%Y-%m-%d'),
        "case_code": self.main_case.try(:serial_no),
        "appraised_unit": self.main_case.try(:appraised_unit).try(:name),
        "center":Organization.find_by(self.main_case.try(:organization_id)).try(:name),
    		"type": MainCase::CASE_STAGE_MAP[self.main_case.case_stage.to_sym]
    	}
   	end 

    def self.check_channel_enum_index(channel_word)
      channel = [   :recived_order,
                    :filed,
                    :create_case,
                    :change_case_status,
                    :apply_filing,
                    :case_online_pay,
                    :apply_bill,
                    :bill_made,
                    :add_case_tip,
                    :submit_payment_order,
                    :submit_refund_order,
                    :confirm_payment_order,
                    :confirm_refund_order ]
      return channel.rindex(channel_word)
    end

    def self.channel_map_reverse
      hash = {}
      Notification::CHANNEL_MAP.each{|k, v| hash["#{v}"]=Notification.check_channel_enum_index(k.to_sym) }
      return hash
    end

end
