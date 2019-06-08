# -*- encoding : utf-8 -*-
class Notification < ApplicationRecord
    belongs_to :user

    enum channel: [ :recived_order, :filed, :create_case, :change_case_status, :apply_filing, :case_online_pay,:apply_bill,:bill_made,:add_case_tip ]

    CHANNEL_MAP = {
      :recived_order=>'收到委托单',
      :filed=>'立案',
      :create_case=>'创建案件',
      :change_case_status=>'案件状态变更',
      :apply_filing=>'申请归档',
      :case_online_pay=>'案件在线付款',
      :apply_bill=>'申请发票',
      :bill_made=>'发票已开',
      :add_case_tip=>'案件新增便签'
  }

    def infos_for_api
    	{
    		"titie": self.title,
    		"description":self.description,
    		"status": (self.status == true)? "已读" : "未读",
    		"created_at": self.created_at.strftime('%Y/%m/%d'),
    		"type": Notification::CHANNEL_MAP[self.channel.to_sym]
    	}
   	end 


end
