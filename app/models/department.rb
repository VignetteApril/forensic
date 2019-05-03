# 科室
class Department < ApplicationRecord
  validates :name, :presence => true, :length => {:maximum => 200}
  validates :code, :presence => true, :length => {:maximum => 20}

  has_ancestry
  has_many :users, dependent: :destroy # 机构中有很多
  belongs_to :organization
end
