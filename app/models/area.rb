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
