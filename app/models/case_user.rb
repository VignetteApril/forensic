# == Schema Information
#
# Table name: case_users
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  main_case_id :bigint
#  pos          :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class CaseUser < ApplicationRecord
  belongs_to :user
  belongs_to :main_case
end
