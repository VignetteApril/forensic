# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  login             :string(50)       not null
#  name              :string(20)
#  email             :string(100)
#  mobile_phone      :string(100)
#  hashed_password   :string
#  salt              :string
#  sort_no           :integer
#  gender            :string(10)
#  address           :string
#  memo              :text
#  changed_password  :boolean
#  orgnization_name  :string(20)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  session_id        :string
#  api_key           :string
#  wechat_id         :string
#  organization_id   :bigint
#  is_locked         :boolean          default(FALSE)
#  user_type         :integer
#  remember_digest   :string
#  departments       :string
#  department_names  :string
#  landline          :string
#  province_id       :integer
#  city_id           :integer
#  district_id       :integer
#  organization_name :string
#  confirm_stage     :integer          default("confirm")
#  form_id           :string
#  open_id           :string
#  is_ban            :boolean          default(FALSE)
#  ident_number      :string
#  commonly_used     :boolean          default(FALSE)
#
require 'digest/sha2'
require 'bcrypt'

class User < ApplicationRecord
  # 宏
  attr_accessor :password_confirmation
  attr_reader   :password
  attr_accessor :remember_token

  # 验证
  validates :login, :presence => true, :uniqueness => true, :length => {:minimum => 1, :maximum => 50}
  validates :name,  :length => {:maximum => 20}
  validates :email, :length => {:maximum => 100}, :format => { :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }, allow_nil: true, allow_blank: true
  validates :gender, :length => {:maximum => 10}
  validates :mobile_phone, :length => {:maximum => 100}
  validates :password, :confirmation => true
  validates :password, :presence => true, on: :create
  validates :password, :length => {:minimum => 6, :maximum => 20}, allow_nil: true # 密码的位数 6 <= password <= 20
  # validate  :password_must_be_present
  # validates :city_id, :presence => true
  # validates :district_id, :presence => true

  # 关联
  has_many   :entrust_orders, dependent: :destroy
  has_many   :express_orders
  has_many   :recive_express_orders
  has_many   :case_talks, dependent: :destroy
  has_many   :user_roles, dependent: :destroy
  has_many   :roles, :through => :user_roles
  has_many   :notifications, dependent: :destroy
  has_many   :sys_logs
  has_many   :favorites, dependent: :destroy
  has_many   :case_memos, dependent: :destroy
  has_one    :case_user
  belongs_to :department, required: false   
  belongs_to :organization, optional: true # 每一个用户只能同时属于一个机构
  has_one_attached :positive #证件正面
  has_one_attached :negative #证件反面

  # callbacks
  before_save  :set_user_type, unless: :organization_empty?
  before_save  :set_user_organization_name, unless: :organization_empty?
  before_save  :set_department_names
  before_save  :set_area_relation

  enum confirm_stage: [:not_confirm, :cancel, :confirm]
  CONFIRM_STAGE_MAP = {
      not_confirm: '未审核',
      confirm: '通过',
      cancel: '驳回',
  }

  def set_area_relation
    #TODO api请求来的数据只有 城市id和区域id 需要设置字段省的id  并且让user belongs to Area里的区域id
  end

  # 用户类型【法院用户，鉴定中心用户】
  enum user_type: [:court_user, :center_user]

  # 所有具有某一权限的用户集合
  def self.has_approval_role(action)
    sql = "SELECT DISTINCT users.* FROM users " +
          "INNER JOIN user_roles ON users.id = user_roles.user_id " +
          "INNER JOIN roles ON user_roles.role_id = roles.id " +
          "INNER JOIN role_features ON roles.id = role_features.role_id " +
          "INNER JOIN features ON role_features.feature_id = features.id " +
          "WHERE features.action_names = '#{action}' " #+
          # "  AND features.controller_name = 'zeros_applicas/nodes' "
    find_by_sql(sql)
  end

  # 用户登录验证方法
  def User.authenticate(login, password)
    if user = find_by_login(login)
      if user.hashed_password == encrypt_password(password, user.salt)
        user
      end
    end
  end

  # 用户密码加密方法
  def User.encrypt_password(password, salt)
    Digest::SHA2.hexdigest(password + "shike" + salt)
  end

  # 'password'作为虚拟属性
  def password=(password)
    @password = password

    if password.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  # 用于SAML登录密码验证
  def valid_password?(password)
    if self.hashed_password == User.encrypt_password(password, self.salt)
      true
    else
      false
    end
  end

  def set_department_names
    self.department_names = Department.where(id: self.departments.split(',')).pluck(:name).join(',') unless self.departments.blank?
  end

  # 判断当前机构是否为空
  def organization_empty?
    self.organization.nil?
  end

  def set_user_type
    case self.organization.org_type.to_sym
    when :court
      self.user_type = :court_user
    when :center
      self.user_type = :center_user
    end
  end

  # 用户创建或者更新时更新用户的organization_name字段
  # organization_name用于展示用户所属的机构名，为了提高速度而设置
  def set_user_organization_name
    self.organization_name = self.organization.name
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 如果指定的令牌和摘要匹配，返回 true
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # 忘记用户
  def forget
    update_attribute(:remember_digest, nil)
  end


  # 判断当前用户是否是平台管理员
  def admin?
    self.login == 'admin'
  end

  # 定义了以下的方法，用来询问当前用户是否是某种角色
  # admin_user?  =>                       询问当前用户是否拥有【系统管理员】角色
  # client_entrust_user? =>               询问当前用户是否拥有【委托人】角色
  # center_admin_user? =>                 询问当前用户是否拥有【鉴定中心管理员】角色
  # center_director_user? =>              询问当前用户是否拥有【鉴定中心主任】角色
  # center_department_director_user? =>   询问当前用户是否拥有【鉴定中心科室主任】角色
  # center_filing_user? =>                询问当前用户是否拥有【鉴定中心立案人】角色
  # center_ident_user? =>                 询问当前用户是否拥有【鉴定中心鉴定人】角色
  # center_assistant_user? =>             询问当前用户是否拥有【鉴定中心鉴定助理】角色
  # center_archivist_user? =>             询问当前用户是否拥有【鉴定中心归档人】角色
  # center_finance_user? =>               询问当前用户是否拥有【鉴定中心财务管理人】角色
  Role::NAME_TYPE.each do |key, value|
    define_method (key.to_s + '?').to_sym do
      self.roles.pluck(:name).map(&:to_sym).include? key
    end
  end

  class << self
    # 生成新的token
    def new_token
      SecureRandom.urlsafe_base64
    end

    # 返回指定字符串的哈希摘要
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                 BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  private

  # 18n代替
  # def password_must_be_present
  #   errors.add(:password, "缺少密码") unless hashed_password.present?
  # end

  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
