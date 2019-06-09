class RefundOrder < ApplicationRecord
	belongs_to :payment_order
end