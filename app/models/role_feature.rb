# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: role_features
#
#  id         :bigint           not null, primary key
#  role_id    :integer          not null
#  feature_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class RoleFeature < ApplicationRecord
  belongs_to :role
  belongs_to :feature
end
