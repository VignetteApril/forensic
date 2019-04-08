# -*- encoding : utf-8 -*-
class SysConfigsController < ApplicationController
  # 系统参数配置首页面
  def index
    init_bread('参数配置')
    @sys_configs = SysConfig.where(gem: '平台')
  end
  
  # 更新保存参数配置
  def update
    begin
      a = SysConfig.find_or_create_by!(gem: '平台', key: 'CUSTOMER_CODE', desc: '客户标识，与授权码匹配，根据授权码所对应的客户标识代码填写')
      a.update!(value: params[:customer_code] || CUSTOMER_CODE)

      a = SysConfig.find_or_create_by!(gem: '平台', key: 'ES_HOST', desc: '索引服务器的IP地址和端口号（例如：0.0.0.0:9200）')
      a.update!(value: params[:es_host] || ES_HOST)

      # a = SysConfig.find_or_create_by!(key: 'BLACK_WORD', desc: '数据检索的时候，需要排除掉的关键字清单，使用英文逗号分隔（例如：公司,部门）')
      # a.update!(value: params[:black_word] || BLACK_WORD)

      a = SysConfig.find_or_create_by!(gem: '平台', key: 'SUPER_ROLES', desc: '系统超级用户的角色名称，使用英文逗号分隔（例如：系统管理员）')
      a.update!(value: params[:super_roles] || SUPER_ROLES)

      a = SysConfig.find_or_create_by!(gem: '平台', key: 'DEPARTMENT_ONLYLEAF_CAN_HAS_USER', desc: '组织结构中是否只有叶子节点可以拥有用户？（填写：是 / 否）')
      a.update!(value: params[:department_onlyleaf_can_has_user] || DEPARTMENT_ONLYLEAF_CAN_HAS_USER)

      a = SysConfig.find_or_create_by!(gem: '平台', key: 'SYS_TITLE', desc: '显示在页面标题栏的系统名称')
      a.update!(value: params[:sys_title] || SYS_TITLE)

      a = SysConfig.find_or_create_by!(gem: '平台', key: 'SYS_SUBTITLE', desc: '显示在页面标题栏的系统名称')
      a.update!(value: params[:sys_subtitle] || SYS_SUBTITLE)

      a = SysConfig.find_or_create_by!(
        gem: '平台', 
        key: 'LIBREOFFICE_DIR', 
        desc: 'LibreOffice软件的路径地址<br>MacOS: /Applications/LibreOffice.app/Contents/MacOS/soffice<br>CentOS: /usr/lib64/libreoffice/program/soffice<br>Ubuntu: /usr/lib/libreoffice/program/soffice'
      )
      a.update!(value: params[:libreoffice_dir] || LIBREOFFICE_DIR)

      a = SysConfig.find_or_create_by!(gem: '平台', key: 'ACCOUNTING_LEVEL', desc: '核算级次（行政区划/所属机构）名称，使用英文逗号分隔（例如：本级,和平区,南开区）')
      a.update!(value: params[:accounting_level] || ACCOUNTING_LEVEL)

      a = SysConfig.find_or_create_by!(gem: '平台', key: 'SYS_LOGO', desc: '系统LOGO图标文件地址')
      a.update!(value: params[:sys_logo] || SYS_LOGO)

      a = SysConfig.find_or_create_by!(gem: 's_rtf', key: 'REDMINE_URL', desc: '项目管理子系统URL地址，如：http://127.0.0.1:4000')
      a.update!(value: params[:redmine_url].to_s)

      a = SysConfig.find_or_create_by!(gem: 's_rtf', key: 'REDMINE_API_KEY', desc: '项目管理子系统的API访问键（我的账号::右侧边栏::API访问键）')
      a.update!(value: params[:redmine_api_key].to_s)

      redirect_to sys_configs_path, notice: '参数配置已经保存！'
    rescue
      redirect_to sys_configs_path, notice: '参数配置保存失败，请联系系统管理员！'
    end
  end
end
