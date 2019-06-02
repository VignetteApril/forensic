require 'barby'
require 'barby/barcode/code_128'

class TransferDoc < ApplicationRecord
  has_one_attached :barcode_png
  belongs_to :main_case

  before_create :set_barcode_hex

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

  def generate_barcode
    if self.barcode
      barcode = Barby::Code128B.new(self.barcode)
      blob = Barby::PngOutputter.new(barcode).to_png

      File.open("#{self.barcode}.png", 'wb'){|f| f.write blob }
    end
  end

  def set_barcode_hex
    self.barcode = SecureRandom.hex 10
  end

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
