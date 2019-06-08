# 科室
class Department < ApplicationRecord
  validates :name, :presence => true, :length => {:maximum => 200}
  validates :code, :presence => true, :length => {:maximum => 20}
  validates :abbreviation, :presence => true, unless: :org_is_court?

  def org_is_court?
    self.organization.is_court?
  end

  has_ancestry
  has_many :department_docs
  belongs_to :organization

  def user_array
    rs_arr = []
    self.organization.users.each do |user|
      next if user.departments.nil?
      rs_arr << user if user.departments.split(',').include? self.id.to_s
    end
    rs_arr
  end
end
