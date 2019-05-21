class TransferDoc < ApplicationRecord
  has_one_attached :attachment
  belongs_to :main_case

  enum unit: [ :piece,
               :meter,
               :cm,
               :liter,
               :kilo,
               :gram ]

  UNIT_MAP = { piece: '个',
               meter: '米',
               cm: '厘米',
               liter: '升',
               kilo: '千克',
               gram: '克' }


  class << self
    # 为前端的显示的方法
    def collection_select_arr
      rs = []
      units.each do |key, value|
        rs << [UNIT_MAP[key.to_sym], key]
      end
      rs
    end
  end
end
