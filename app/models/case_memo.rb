class CaseMemo < ApplicationRecord
  belongs_to :user
  belongs_to :main_case

  # 仅自己（这个是案件鉴定人的默认选项）
  # 本案件内部（本案件的鉴定人可见）
  # 本案件（本案件的鉴定人 + 委托联系人）（这个是委托人的默认选项）
  # 本案件和领导（本案件的鉴定人 + 委托联系人 + 鉴定中心科室主任）
  enum visibility_range: [ :only_me, :inner_current_case, :current_case, :current_case_and_leader ]
  VISIBILITY_RANGE_MAP = { only_me: '只有我',
                           inner_current_case: '案件内部',
                           current_case: '本案件',
                           current_case_and_leader: '本案件和领导' }
  validates_presence_of :visibility_range, :content

  class << self
    def visibility_range_collection
      rs = []
      visibility_ranges.each do |key, value|
        rs << [VISIBILITY_RANGE_MAP[key.to_sym], key]
      end
      rs
    end
  end
end
