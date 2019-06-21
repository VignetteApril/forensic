# -*- encoding : utf-8 -*-
class Notification < ApplicationRecord
    belongs_to :user
    belongs_to :main_case

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
        "id":self.id,
    		"titie": self.title,
    		"description":self.description,
    		"status": self.status ,
    		"created_at": self.created_at.strftime('%Y/%m/%d'),
        "case_code": self.main_case.try(:case_no),
        "appraised_unit": self.main_case.try(:appraised_unit).try(:name),
        "center":Organization.find_by(self.main_case.organization_id).try(:name),
    		"type": Notification::CHANNEL_MAP[self.channel.to_sym]
    	}
   	end 


end
