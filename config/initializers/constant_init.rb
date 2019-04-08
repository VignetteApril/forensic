# -*- encoding : utf-8 -*-

ES_HOST = YAML.load_file(Rails.root.join("config","config.yml"))["elasticsearch_host"]
BLACK_WORD = YAML.load_file(Rails.root.join("config", "config.yml"))["black_word"]
SUPER_ROLES = YAML.load_file(Rails.root.join("config","config.yml"))["super_roles"]
DEPARTMENT_ONLYLEAF_CAN_HAS_USER = YAML.load_file(Rails.root.join("config","config.yml"))["department_onlyleaf_can_has_user"]
ACCOUNTING_LEVEL = YAML.load_file(Rails.root.join("config","config.yml"))["accounting_level"]
CUSTOMER_CODE = YAML.load_file(Rails.root.join("config","config.yml"))["customer_code"]
LIBREOFFICE_DIR = YAML.load_file(Rails.root.join("config","config.yml"))["libreoffice_dir"]
SYS_TITLE = YAML.load_file(Rails.root.join("config","config.yml"))["title"]
SYS_SUBTITLE = YAML.load_file(Rails.root.join("config","config.yml"))["subtitle"]

# #############################

FILE_DIR = Rails.root.join("public")
# FILE_DIR = YAML.load_file(Rails.root.join("config","config.yml"))["file_dir"]
PROVIDER = YAML.load_file(Rails.root.join("config","config.yml"))["provider"]
AVERSION = YAML.load_file(Rails.root.join("config","config.yml"))["aversion"]

GEM_LIST = YAML.load_file(Rails.root.join("config","config.yml"))["gem_list"]
FEATURES = YAML.load_file(Rails.root.join("config","config.yml"))["features"]
INTERNAL_TABLES = YAML.load_file(Rails.root.join("config","config.yml"))["internal_tables"]

# 遍历所有插件中的module_chain
apps = YAML.load_file(Rails.root.join("config","config.yml"))["apps"]
# Dir::foreach(Rails.root.join("config", "engine_configs")) do |f|
  # if f != '.' && f != '..' && f[0] != '.' && YAML.load_file(Rails.root.join("config","engine_configs", f))["app"]
    # puts YAML.load_file(Rails.root.join("config","engine_configs", f))["app"].to_s
    # app = YAML.load_file(Rails.root.join("config","engine_configs", f))["app"]
    # apps.push(app)
    # apps.each_key do |k|
      # apps[k]['icons'].each_index do |i|
        # if apps[k]['icons'][i]['id'] && apps[k]['icons'][i]['id'] == app['name']
          # if apps[k]['icons'][i]['done'] == 'group'
            # apps[k]['icons'][i]['icons'] = app['icons']
          # else
            # apps[k]['icons'][i]['module_chain'] = app['module_chain']
          # end
          # break
        # end
      # end
    # end
  # end
# end
APPS = apps
# puts APPS
# EXTERNAL_APPS = YAML.load_file(Rails.root.join("config","config.yml"))["external_apps"]

# ##########

UPLOAD_FILE_NAME = YAML.load_file(Rails.root.join("config","config.yml"))["upload_file_name"]
FORBID_SHADOW_LOGIN = YAML.load_file(Rails.root.join("config","config.yml"))["forbid_shadow_login"]
USE_CAS_SERVER = YAML.load_file(Rails.root.join("config","config.yml"))["use_cas_server"]

# 这里需要遍历所有插件所加入的notification
notification_channels = YAML.load_file(Rails.root.join("config","config.yml"))["notification_channels"] || []
# Dir::foreach(Rails.root.join("config", "engine_configs")) do |f|
  # if f != '.' && f != '..' && YAML.load_file(Rails.root.join("config","engine_configs", f))["notification_channels"]
    # notification_channels += YAML.load_file(Rails.root.join("config","engine_configs", f))["notification_channels"]
  # end
# end
NOTIFICATION_CHANNELS = notification_channels

# ##########

USER_POLITICS_STATUS = YAML.load_file(Rails.root.join("config","config.yml"))["user_politics_status"]
USER_ID_TYPE = YAML.load_file(Rails.root.join("config","config.yml"))["user_id_type"]
USER_GENDER = YAML.load_file(Rails.root.join("config","config.yml"))["user_gender"]
USER_MARITAL_STATUS = YAML.load_file(Rails.root.join("config","config.yml"))["user_marital_status"]
USER_EDUCATION = YAML.load_file(Rails.root.join("config","config.yml"))["user_education"]
USER_DEGREE = YAML.load_file(Rails.root.join("config","config.yml"))["user_degree"]
USER_RANK = YAML.load_file(Rails.root.join("config","config.yml"))["user_rank"]

PROVINCE = YAML.load_file(Rails.root.join("config","config.yml"))["province"]
CITY = YAML.load_file(Rails.root.join("config","config.yml"))["city"]
THEME = YAML.load_file(Rails.root.join("config","config.yml"))["theme"]
SKIN = YAML.load_file(Rails.root.join("config","config.yml"))["skin"]

# 系统更新记录
RELEASE_NOTES = YAML.load_file(Rails.root.join("config","release.yml"))["release_notes"]

