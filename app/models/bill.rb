class Bill < ApplicationRecord
	belongs_to :main_case
	has_many :payment_orders
end