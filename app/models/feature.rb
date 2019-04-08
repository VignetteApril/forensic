# -*- encoding : utf-8 -*-
class Feature < ActiveRecord::Base
  has_many :role_features, dependent: :delete_all
  has_many :roles, through: :role_features
end
