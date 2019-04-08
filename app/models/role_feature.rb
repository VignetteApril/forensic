# -*- encoding : utf-8 -*-
class RoleFeature < ActiveRecord::Base
  belongs_to :role
  belongs_to :feature
end
