# -*- encoding : utf-8 -*-
class Favorite < ApplicationRecord
  belongs_to :user
  
  validates :title, :presence => true, :length => {:minimum => 1, :maximum => 255}
  validates :url, :presence => true, :length => {:minimum => 1}
end
