# 科室
class Department < ApplicationRecord
  validates :name, :presence => true, :length => {:maximum => 200}, uniqueness: { message: '该科室名称已经被占用！' }
  validates :code, :presence => true, :length => {:maximum => 20}, uniqueness: { message: '该编号已经被占用' }
  validates :abbreviation, :presence => true

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
