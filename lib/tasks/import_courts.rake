desc '导入法院'
task :import_courts_data => :environment do
  file = File.read(Rails.root.join("public", "courts.json"))
  courts = JSON.parse(file)['data']
  fails = []
  courts.each do |court|
  	if !Organization.where(:name=>court["name"]).exists?
	  	province_id = Area.roots.where(:name=>court["province"]).try(:first).try(:id)
	  	c = Organization.new(name: court["name"],level:court["level"],province_id:province_id,area_id:province_id,org_type: :court)
	  	unless c.save
	  		puts "----------------------->"
	  		puts "#{c.errors.messages}"
	  		fails.push(court)
	  	end
  	end
  end
  #TODO 军事法院没有province
  puts "导入完毕 失败#{fails.count}条"
  puts "#{fails}"
end