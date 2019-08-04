require 'barby'
require 'barby/barcode/ean_13'
require 'barby/outputter/png_outputter'

class TransferDoc < ApplicationRecord
  has_one_attached :barcode_image
  belongs_to :main_case

  before_create :set_barcode_hex
  after_destroy :purge_barcode_image

  # 设置移交材料的序号
  before_validation( :on => :create ) do
    self.serial_no = self.main_case.transfer_docs.collect { | doc | doc.serial_no }.max + 1
  end

  # 设置条码，并且生成条码图片
  def set_barcode_hex
    self.barcode = Time.now.strftime('%Y%m%d%H%M')
    barcode = Barby::EAN13.new(self.barcode)
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
    def collection_select_arr
      [['个', '个'],
       ['米' , '米'],
       ['厘米','厘米'],
       ['升','升'],
       ['千克','千克'],
       ['克','克'],
       ['件', '件'],
       ['条','条'],
       ['张', '张'],
       ['份', '份'],
       ['根', '根'],
       ['捆', '捆'],
       ['毫升', '毫升'],
       ['毫米', '毫米'],
       ['罐', '罐'],
       ['管', '管'],
       ['瓶', '瓶'],
       ['具', '具'],
       ['册/页', '册/页'],
       ['微米', '微米']]
    end
  end
end
