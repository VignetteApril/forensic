class Bill < ApplicationRecord
	belongs_to :payment_order
end