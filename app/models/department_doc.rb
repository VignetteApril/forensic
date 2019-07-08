class DepartmentDoc < ApplicationRecord
  belongs_to :docable, polymorphic: true
  has_one_attached :attachment

  validates :name, presence: { message: '名称不能为空' }
  validates :doc_code, presence: { message: '文件编码不能为空' }
  validates :case_stage, presence: { message: '案件阶段不能为空' }

  enum case_stage: [ :base_info,
                     :add_materials,
                     :filed,
                     :reject_case,
                     :financial,
                     :executing,
                     :archived ]

  CASE_STAGE_MAP = { base_info: '基本信息',
                     add_materials: '补充材料',
                     filed: '立案',
                     reject_case: '退案',
                     financial: '财务管理',
                     executing: '鉴定执行',
                     archived: '归档' }

  def case_stage_cn_name
    CASE_STAGE_MAP[self.case_stage.to_sym]
  end

  def is_case_doc?
    self.docable_type.to_sym == :main_case
  end

  class << self
    def collection_select_arr
      rs = []
      case_stages.each do |key, value|
        rs << [CASE_STAGE_MAP[key.to_sym], key]
      end
      rs
    end

    def collection_filter_arr
      rs = []
      case_stages.each do |key, value|
        rs << [CASE_STAGE_MAP[key.to_sym], value]
      end
      rs
    end
  end
end
