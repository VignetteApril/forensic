# == Schema Information
#
# Table name: doc_templates
#
#  id         :bigint           not null, primary key
#  name       :string
#  desc       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class DocTemplate < ApplicationRecord
  has_one_attached :attachment

  before_save :set_template_name, on: [:create, :update]

  def set_template_name
    self.name = attachment.blob.filename
  end

  class << self
    def collection_templates
      rs = []
      self.all.each do |template|
        rs << [template.name, template.id]
      end
      rs
    end
  end
end
