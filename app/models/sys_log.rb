# -*- encoding : utf-8 -*-
# require 'elasticsearch/model'

class SysLog < ActiveRecord::Base
  belongs_to :user
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
end
