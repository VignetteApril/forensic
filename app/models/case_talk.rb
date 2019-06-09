class CaseTalk < ApplicationRecord
	belongs_to :user
	belongs_to :main_case
end