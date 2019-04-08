# -*- encoding : utf-8 -*-
class DelayedJobsController < ApplicationController
  # 任务管理主页面
  def index
    init_bread('任务管理')
  end
end
