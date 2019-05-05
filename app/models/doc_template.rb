class DocTemplate < ApplicationRecord
  has_one_attached :attachment

  before_save :set_template_name, on: [:create, :update]

  def set_template_name
    self.name = attachment.blob.filename
  end
end
