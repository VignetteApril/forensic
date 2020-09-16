# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: sys_logs
#
#  id          :bigint           not null, primary key
#  user_id     :integer
#  log_content :text
#  log_date    :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SysLog < ApplicationRecord
  belongs_to :user
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
end
