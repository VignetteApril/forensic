# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: features
#
#  id              :bigint           not null, primary key
#  name            :string
#  controller_name :string
#  action_names    :string
#  role_names      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  app             :string
#
class Feature < ApplicationRecord
  has_many :role_features, dependent: :delete_all
  has_many :roles, through: :role_features
end
