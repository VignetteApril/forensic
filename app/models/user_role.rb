# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: user_roles
#
#  id         :bigint           not null, primary key
#  user_id    :integer          not null
#  role_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserRole < ApplicationRecord
  validates :user_id, :presence => true
  validates :role_id, :presence => true
  
  belongs_to :user
  belongs_to :role
end
