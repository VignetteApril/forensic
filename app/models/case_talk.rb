# == Schema Information
#
# Table name: case_talks
#
#  id           :bigint           not null, primary key
#  user_id      :integer
#  detail       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  main_case_id :integer
#
class CaseTalk < ApplicationRecord
	belongs_to :user
	belongs_to :main_case
end
