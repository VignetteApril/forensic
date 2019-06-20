class AppraisedUnit < ApplicationRecord
  belongs_to :main_case, required:false

  enum unit_type: [ :unit, :user ]
  enum gender: [:male, :female]
  enum id_type: [:user_id, :other]

  UNIT_TYPE_MAP = { unit: '单位', user: '个人' }
  GENDER_MAP = { male: '男', female: '女' }
  ID_TYPE = { user_id: '身份证', other: '其他' }

  class << self
    def unit_types_arr
      rs = []
      unit_types.each do |key, value|
        rs << [UNIT_TYPE_MAP[key.to_sym], key]
      end
      rs
    end

    def genders_arr
      rs = []
      genders.each do |key, value|
        rs << [GENDER_MAP[key.to_sym], key]
      end
      rs
    end

    def id_types_arr
      rs = []
      id_types.each do |key, value|
        rs << [ID_TYPE[key.to_sym], key]
      end
      rs
    end
  end


end
