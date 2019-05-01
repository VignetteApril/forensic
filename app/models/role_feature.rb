# -*- encoding : utf-8 -*-
class RoleFeature < ApplicationRecord
  belongs_to :role
  belongs_to :feature
end
