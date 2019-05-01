class Area < ApplicationRecord
  has_ancestry
  enum area_type: [ :province, :city, :district ]
end
