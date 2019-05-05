json.extract! doc_template, :id, :name, :desc, :created_at, :updated_at
json.url doc_template_url(doc_template, format: :json)
