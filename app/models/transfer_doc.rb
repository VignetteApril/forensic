class TransferDoc < ApplicationRecord
  has_one_attached :attachment

  belongs_to :main_case
end
