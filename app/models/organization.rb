class Organization < ApplicationRecord

  belongs_to :area

  # 组织类型对照表
  ORG_TYPE_MAP = { court: '法院',
                   center: '鉴定中心'}
  enum org_type: [:court, :center]


end
