# -*- encoding : utf-8 -*-
class SysLogsController < ApplicationController
  # 管理员进入“日志管理”页面，系统显示日志列表页面。 
  # 日志列表默认安装时间戳进行倒序排列，并且进行分页处理。 
  # 管理员可以根据时间段、登录用户、对应的控制器和对应的 Action 等条件进行筛选。也可以针对返回的错误信息进行模糊查找。
  def index
    init_bread('日志管理')
    @sys_logs = initialize_grid(SysLog, per_page: 100,
                                name: 'sys_logs',
                                order: 'updated_at',
                                order_direction: 'desc',
                                enable_export_to_csv: true,
                                csv_file_name: 'sys_logs')
    export_grid_if_requested
  end
  
  # 查看某一条日志内容
  def show
    cal_bread('查看日志信息')
    @search_content = params[:search_content]
    @sys_log = SysLog.find(params[:id])
  end
  
  # 用户查看日志全文搜索结果
  # def search
    # cal_bread('日志全文检索')
    # @search_content = params[:search_content]
    # @search_results = SysLog.search(@search_content, size: MAX_SEARCH_SIZE).records
    # @search_results = initialize_grid(@search_results.records,
                                      # per_page: 20,
                                      # name: 'sys_logs_search')
  # end
end
