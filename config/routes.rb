Rails.application.routes.draw do
  resources :material_cycles
  resources :identification_cycles
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
    post :create_case_doc, on: :member
    patch :update_add_material, on: :member
    patch :update_filing, on: :member
    patch :update_reject, on: :member
  end

  post 'areas/cities'
  post 'areas/districts'

  get 'aologin' => 'session#aologin'
  get 'aosignin' => 'session#aosignin'
  get 'ao' => 'session#ao'

  get 'login' => 'session#new', as: :login
  get 'logout' => 'session#destroy', as: :logout

  # root 'main_cases#index'
  root 'session#index'
end

