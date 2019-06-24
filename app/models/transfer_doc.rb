require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class TransferDoc < ApplicationRecord
  has_one_attached :barcode_image
  belongs_to :main_case

  before_create :set_barcode_hex
  after_destroy :purge_barcode_image

  # enum unit: [ :piece,
  #              :meter,
  #              :cm,
  #              :liter,
  #              :kilo,
  #              :gram ]

  # UNIT_MAP = { piece: '个',
  #              meter: '米',
  #              cm: '厘米',
  #              liter: '升',
  #              kilo: '千克',
  #              gram: '克' }

  # 设置条码，并且生成条码图片
  def set_barcode_hex
    self.barcode = SecureRandom.hex 10
    barcode = Barby::Code128B.new(self.barcode)
    blob = Barby::PngOutputter.new(barcode).to_png
    self.barcode_image.attach io: StringIO.new(blob),
                            filename: self.barcode + '.png',
                            content_type: 'image/png'
  end

  # 当移交资料删除时，对应二维码文件也要删除
  def purge_barcode_image
    self.barcode_image.purge
  end

  class << self
    # 为前端的显示的方法
    # def collection_select_arr
    #   rs = []
    #   units.each do |key, value|
    #     rs << [UNIT_MAP[key.to_sym], key]
    #   end
    #   rs
    # end

    def collection_select_arr
      [['个', '个'], ['米' , '米'], ['厘米','厘米'], ['升','升'], ['千克','千克'], ['克','克']]
    end
  end
end
