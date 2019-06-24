Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  match "/delayed_job" => BetterDelayedJobWeb, :anchor => false, :via => [:get, :post]

  resources :delayed_jobs
  resources :favorites
  resources :notifications
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
    get :new_consignor, :on => :collection
    post :create_consignor, :on => :collection
    get :reset_password, :on => :member
    get :edit_password, :on => :member
    post :update_password, :on => :member
    get :list, on: :collection
    get :show_api_key, on: :member
    post :generate_api_key, on: :member
  end

  resources :session do
    get :ao, on: :collection
    get :aologin, on: :collection
    post :aosignin, on: :collection
  end

  resources :organizations
  resources :doc_templates
  resources :main_cases do
    get :organization_and_user, on: :collection
    get :matter_demands_and_case_types, on: :collection
    get :generate_case_no, on: :member
    get :filing_info, on: :member
    get :open_barcode_image, on: :collection
    get :payment, on: :member
    get :department_cases, on: :collection
    get :center_cases, on: :collection
    get :filed_unpaid_cases, on: :collection
    get :payment_order_management, on: :member
    get :request_bill, on: :collection
    get :case_executing, on: :member
    post :display_dynamic_file_modal, on: :member
    post :create_organization_and_user, on: :collection
    post :user_search, on: :collection
    post :create_case_doc, on: :member
    post :update_bill, on: :collection
    patch :update_case_stage, on: :member
    patch :update_add_material, on: :member
    patch :update_filing, on: :member
    patch :update_reject, on: :member
    patch :save_payment_order, on: :member
  end

  resources :material_cycles
  resources :identification_cycles

  resources :entrust_orders do
    get :org_orders, on: :collection
  end

  post 'areas/cities'
  post 'areas/districts'

  get 'login' => 'session#new', as: :login
  get 'logout' => 'session#destroy', as: :logout

  # 小程序后台API
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

