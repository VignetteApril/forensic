Rails.application.routes.draw do
  resources :recive_express_orders
  resources :express_orders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  match "/delayed_job" => BetterDelayedJobWeb, :anchor => false, :via => [:get, :post]

  resources :delayed_jobs
  resources :favorites
  resources :notifications do
    get :all_readed, :on => :collection
  end
  resources :sys_configs
  resources :sys_logs do
    get :search, on: :collection
  end

  resources :features do
    get :list, :on => :collection
    get :role_features_grid, :on => :member
    get :add_features, :on => :member
    get :add_features_submit, :on => :member
    delete :remove_feature_from_role, :on => :member
  end

  resources :roles do
    get :role_users_grid, :on => :member
    get :add_users, :on => :member
    get :add_users_submit, :on => :member
    delete :remove_user_from_role, :on => :member
  end

  resources :departments do
    resources :department_docs
    get :department, :on => :member
    get :add_users, :on => :member
    get :add_users_submit, :on => :member
    delete :remove_user_from_department, :on => :member
  end
  resources :users do
    get :edit_self, :on => :member
    put :update_edit_self, :on => :member
    get :new_consignor, :on => :collection
    post :create_consignor, :on => :collection
    get :reset_password, :on => :member
    get :edit_password, :on => :member
    post :update_password, :on => :member
    get :list, on: :collection
    get :show_api_key, on: :member
    post :generate_api_key, on: :member
    get :confirm_users,  :on => :collection
    get :confirm_user,  :on => :member
    get :cancel_user,  :on => :member
    get :edit_org,:on => :member
    post :update_confirm_user_org,:on => :member
  end

  resources :session do
    get :ao, on: :collection
    get :aologin, on: :collection
    post :aosignin, on: :collection
  end

  resources :organizations
  resources :doc_templates
  resources :main_cases do
    get :personal_count,  :on => :collection
    get :organization_and_user, on: :collection
    get :matter_demands_and_case_types, on: :collection
    get :generate_case_no, on: :member
    get :filing_info, on: :member
    get :open_barcode_image, on: :collection
    get :payment, on: :member
    get :department_cases, on: :collection
    get :center_cases, on: :collection
    get :wtr_cases, on: :collection
    get :filed_unpaid_cases, on: :collection
    get :apply_filing_cases, on: :collection
    get :payment_order_management, on: :member
    get :request_bill, on: :collection
    get :case_executing, on: :member
    get :pending_cases, on: :collection
    get :new_with_entrust_order, on: :collection
    get :closing_case, on: :member
    get :case_memos, on: :member
    get :case_process_records, on: :member
    post :create_case_memo, on: :member
    post :update_doc_is_passed, on: :collection
    post :display_dynamic_file_modal, on: :member
    post :create_organization_and_user, on: :collection
    post :user_search, on: :collection
    post :create_case_doc, on: :member
    post :update_bill, on: :collection
    patch :update_case_stage, on: :member
    patch :update_financial_stage, on: :member
    patch :update_add_material, on: :member
    patch :update_filing, on: :member
    patch :update_reject, on: :member
    patch :save_payment_order, on: :member

    # 缴费单
    resources :payment_orders do
      get :submit_current_order, on: :member
      get :finance_index, on: :collection
      get :confirm_order, on: :member
      patch :cancel_order, on: :member
    end

    # 发票
    resources :bills do
      get :finance_index, on: :collection
      post :dyn_form_modal, on: :member
      patch :to_billed, on: :member
      patch :to_taked_away, on: :member
    end
    
    # 退费单
    resources :refund_orders do
      get :submit_current_order, on: :member
      get :finance_index, on: :collection
      get :confirm_order, on: :member
      patch :cancel_order, on: :member
    end
  end

  resources :material_cycles
  resources :identification_cycles

  resources :entrust_orders do
    get :org_orders, on: :collection
    get :org_orders_unclaimed, on: :collection
  end

  resources :incoming_records do
    get :claim_record_index, on: :member
    get :claim_record_list, on: :collection
    post :get_payment_order, on: :collection
    patch :claim_record, on: :member
  end

  post 'areas/cities'
  post 'areas/districts'

  get 'login' => 'session#new', as: :login
  get 'logout' => 'session#destroy', as: :logout
  # 打开word在线编辑页面
  get 'edit_office_online/edit_office'
  # 保存word文档
  post 'edit_office_online/save_doc'
  # 刷新页面
  post 'edit_office_online/get_doc_url'
  # 下载控件
  get 'edit_office_online/download_weboffice'

  # 小程序后台API
  post 'apis/wx_msg_send'
  post 'apis/wx_msg_code_to_session'
  post 'apis/register'
  get 'apis/get_search_courts'
  get 'apis/get_search_centers'
  post 'apis/login'
  put 'apis/update_user_infos'
  get 'apis/get_user_infos'
  get 'apis/get_city_list'
  get 'apis/get_district_list'
  put 'apis/change_notice_status'
  get 'apis/get_notice_list'
  get 'apis/get_case_list'
  get 'apis/get_case_detail_progress'
  get 'apis/get_case_talk'
  get 'apis/get_organization'
  post 'apis/create_appraised_unit'
  get  'apis/get_appraised_unit'
  post 'apis/cerate_entrust_order'
  get  'apis/get_entrust_orgs'
  post 'apis/create_talk'
  get  'apis/get_case_notice_list'

  root 'session#index'
end

