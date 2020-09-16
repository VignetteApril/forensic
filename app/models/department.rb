# == Schema Information
#
# Table name: departments
#
#  id              :bigint           not null, primary key
#  name            :string(200)      not null
#  description     :text
#  parent_id       :string
#  ancestry        :string
#  sort_no         :integer
#  code            :string(20)       default("0000000000"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint
#  matter          :string
#  case_types      :string
#  abbreviation    :string
#  case_start_no   :integer
#
# 科室
class Department < ApplicationRecord
  validates :name, :presence => true, :length => {:maximum => 200}
  validates :code, :presence => true, :length => {:maximum => 20}
  validates :abbreviation, :presence => true, unless: :org_is_court?
  validates :matter, :presence => true
  validates :case_types, :presence => true

  def org_is_court?
    self.organization.is_court?
  end

  has_ancestry
  has_many :department_docs, as: :docable
  has_many :main_cases, dependent: :destroy
  has_many :entrust_orders
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
