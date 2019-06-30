json.extract! incoming_record, :id, :status, :pay_account, :pay_person_name, :amount, :created_at, :updated_at
json.url incoming_record_url(incoming_record, format: :json)
