# == Schema Information
#
# Table name: case_process_records
#
#  id           :bigint           not null, primary key
#  main_case_id :bigint
#  detail       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class CaseProcessRecord < ApplicationRecord
  belongs_to :main_case
end
