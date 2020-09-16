# == Schema Information
#
# Table name: identification_cycles
#
#  id              :bigint           not null, primary key
#  day             :integer
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class IdentificationCycle < ApplicationRecord
  belongs_to :organization
end
