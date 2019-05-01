# -*- encoding : utf-8 -*-
class UserRole < ApplicationRecord
  validates :user_id, :presence => true
  validates :role_id, :presence => true
  
  belongs_to :user
  belongs_to :role
end
