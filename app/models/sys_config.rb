class SysConfig < ApplicationRecord
  validates :key, :presence => true, :uniqueness => true, :length => {:minimum => 1, :maximum => 100}

  def self.es_host
    begin
      h = self.find_by(key: 'ES_HOST')&.value.blank? ? ES_HOST : self.find_by(key: 'ES_HOST').value
    rescue
      h = 'localhost:9200'
    end
    return h
  end

  # def self.black_word
  #   return self.find_by(key: 'BLACK_WORD')&.value.blank? ? BLACK_WORD : self.find_by(key: 'BLACK_WORD').value.split(',').map{ |b| b.strip }
  # end

  def self.super_roles
    return self.find_by(key: 'SUPER_ROLES')&.value.blank? ? SUPER_ROLES : self.find_by(key: 'SUPER_ROLES').value.split(',').map{ |b| b.strip }
  end

  def self.department_onlyleaf_can_has_user?
    return self.find_by(key: 'DEPARTMENT_ONLYLEAF_CAN_HAS_USER')&.value.blank? ? DEPARTMENT_ONLYLEAF_CAN_HAS_USER : (self.find_by(key: 'DEPARTMENT_ONLYLEAF_CAN_HAS_USER').value == '是' ? true : false)
  end

  def self.accounting_level
    return self.find_by(key: 'ACCOUNTING_LEVEL')&.value.blank? ? ACCOUNTING_LEVEL : self.find_by(key: 'ACCOUNTING_LEVEL').value.split(',').map{ |b| b.strip }
  end

  def self.customer_code
    return self.find_by(key: 'CUSTOMER_CODE')&.value.blank? ? CUSTOMER_CODE : self.find_by(key: 'CUSTOMER_CODE').value
  end

  def self.sys_title
    return self.find_by(key: 'SYS_TITLE')&.value.blank? ? SYS_TITLE : self.find_by(key: 'SYS_TITLE').value
  end

  def self.sys_subtitle
    return self.find_by(key: 'SYS_SUBTITLE')&.value.blank? ? SYS_SUBTITLE : self.find_by(key: 'SYS_SUBTITLE').value
  end

  def self.libreoffice_dir
    return self.find_by(key: 'LIBREOFFICE_DIR')&.value.blank? ? LIBREOFFICE_DIR : self.find_by(key: 'LIBREOFFICE_DIR').value
  end

  def self.sys_logo
    return self.find_by(key: 'SYS_LOGO')&.value.blank? ? 'logo.png' : self.find_by(key: 'SYS_LOGO').value
  end

  def self.redmine_url
    return self.find_by(key: 'REDMINE_URL')&.value.to_s
  end

  def self.redmine_api_key
    return self.find_by(key: 'REDMINE_API_KEY')&.value.to_s
  end
end
