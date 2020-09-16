# == Schema Information
#
# Table name: areas
#
#  id         :bigint           not null, primary key
#  name       :string
#  code       :integer
#  area_type  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ancestry   :string
#
class Area < ApplicationRecord
  has_ancestry
  enum area_type: [ :province, :city, :district ]

  def display_name
    ancestors_names = ancestors.map(&:name).join('/')
    if ancestors_names.empty?
      name
    else
      ancestors_names + '/' + name
    end
  end
end
