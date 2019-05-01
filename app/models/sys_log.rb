# -*- encoding : utf-8 -*-
# require 'elasticsearch/model'

class SysLog < ApplicationRecord
  belongs_to :user
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
end
