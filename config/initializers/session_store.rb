# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_shike_session'

if USE_CAS_SERVER
  require 'rack-cas/session_store/rails/active_record'
  Rails.application.config.session_store ActionDispatch::Session::RackCasActiveRecordStore
else
  Rails.application.config.session_store :active_record_store, :key => '_shike_session'
end