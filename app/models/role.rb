# -*- encoding : utf-8 -*-
class Role < ApplicationRecord
  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 50}
  
  has_many :user_roles, dependent: :delete_all
  has_many :users, :through => :user_roles
  
  has_many :role_features, dependent: :delete_all
  has_many :features, through: :role_features
end
