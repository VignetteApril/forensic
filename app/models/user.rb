# -*- encoding : utf-8 -*-
require 'digest/sha2'

class User < ApplicationRecord
  validates :login, :presence => true, :uniqueness => true, :length => {:minimum => 1, :maximum => 50}
  validates :name, :length => {:maximum => 20}
  validates :email, :length => {:maximum => 100}, :format => { :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }, allow_nil: true, allow_blank: true
  validates :gender, :length => {:maximum => 10}
  validates :mobile_phone, :length => {:maximum => 100}
  validates :password, :confirmation => true
  validates :password, :presence => true, on: :create
  validates :password, format: { with: /(?![0-9a-z]+$)(?![a-zA-Z]+$)(?![0-9A-Z]+$)[\S]{8,}/ }, allow_nil: true
  validates :department_id, :presence => false

  attr_accessor :password_confirmation
  attr_reader   :password

  validate :password_must_be_present

  has_many :user_roles, dependent: :delete_all
  has_many :roles, :through => :user_roles
  # 每一个用户只能同时属于一个部门（根据发布系统公告的权限以及系统对于用户查看被审计对象资料数据权限的控制原则可以看出）
  belongs_to :department, required: false
  belongs_to :organization, required: false

  has_many :notifications
  has_many :sys_logs

  has_many :favorites

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

  # 是否是平台管理员
  def admin?
    if self.login == 'admin'
      true
    else
      false
    end
  end

  private

  def password_must_be_present
    errors.add(:password, "缺少密码") unless hashed_password.present?
  end

  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
end
