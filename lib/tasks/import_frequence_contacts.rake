require 'csv'

desc '倒入常用联系人'
task :import_frequence_contacts => :environment do
  csv = CSV.read(Rails.root.join("data", "frequence_contacts.csv"))
  csv.each_with_index do |row, index|
    next if index == 0
    province = Area.province.find_by(name: row[1])
    city = Area.city.find_by(name: row[2])
    district = Area.district.find_by(name: row[3])
    FrequentContact.create!(name: row[0],
                            province_id: province.try(:id),
                            city_id: city.try(:id),
                            district_id: district.try(:id),
                            client_name: row[4],
                            phone: row[5],
                            organization_id: Organization.first.id)
  end
end
