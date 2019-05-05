# 科室
class Department < ApplicationRecord
  validates :name, :presence => true, :length => {:maximum => 200}, uniqueness: { message: '该科室名称已经被占用！' }
  validates :code, :presence => true, :length => {:maximum => 20}, uniqueness: { message: '该编号已经被占用' }

  has_ancestry
  has_many :users, dependent: :destroy # 机构中有很多
  belongs_to :organization
end
