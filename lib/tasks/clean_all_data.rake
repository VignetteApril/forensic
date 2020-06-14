desc '清除所有数据，除了用户科室机构'
task :clean_all_data => :environment do
  begin
    puts "开始清除数据..."
    ActiveRecord::Base.transaction do
      MainCase.destroy_all
      AppraisedUnit.destroy_all
      Bill.destroy_all
      CaseMemo.destroy_all
      CaseProcessRecord.destroy_all
      CaseTalk.destroy_all
      CaseUser.destroy_all
      Department.destroy_all
      DocTemplate.destroy_all
      EntrustOrder.destroy_all
      ExpressOrder.destroy_all
      Favorite.destroy_all
      IdentificationCycle.destroy_all
      IncomingRecord.destroy_all
      MaterialCycle.destroy_all
      Notification.destroy_all
      PaymentOrder.destroy_all
      ReciveExpressOrder.destroy_all
      RefundOrder.destroy_all
      TransferDoc.destroy_all
      Organization.where.not(name: '北京明正司法鉴定中心').destroy_all
      User.update_all(department_names: nil, departments: nil)
    end
  rescue Exception => e
    puts "清除数据中发生报错：#{e.to_s}"
  end


  puts "清除数据完成。"
end