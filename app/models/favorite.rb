# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: favorites
#
#  id         :bigint           not null, primary key
#  user_id    :integer          not null
#  title      :string           not null
#  url        :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Favorite < ApplicationRecord
  belongs_to :user
  
  validates :title, :presence => true, :length => {:minimum => 1, :maximum => 255}
  validates :url, :presence => true, :length => {:minimum => 1}
end
