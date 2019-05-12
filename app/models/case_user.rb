class CaseUser < ApplicationRecord
  belongs_to :user
  belongs_to :main_case
end
