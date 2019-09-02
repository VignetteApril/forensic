class AppraisedUnit < ApplicationRecord
  belongs_to :main_case, required:false
  # has_many :entrust_orders

  enum unit_type: [ :unit, :user ]
  enum gender: [:male, :female]
  enum id_type: [:user_id, :other, :passport, :hong_kong_and_macau_pass]

  before_save :set_birthday, if: -> { self.user? }

  UNIT_TYPE_MAP = { unit: '单位', user: '个人' }
  GENDER_MAP = { male: '男', female: '女' }
  ID_TYPE = { user_id: '身份证', passport: '护照', hong_kong_and_macau_pass: '港澳通行证', other: '其他' }

  def set_birthday
    if self.birthday.blank? && self.id_num.length == 18
      self.birthday = self.id_num[6..13]
    end
  end

  class << self
    def unit_types_arr
      rs = []
      unit_types.each do |key, value|
        rs << [UNIT_TYPE_MAP[key.to_sym], key]
      end
      rs.reverse
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
