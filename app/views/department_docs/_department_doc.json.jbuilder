json.extract! department_doc, :id, :name, :filename, :doc_code, :status, :check_archived, :check_archived_no, :created_at, :updated_at
json.url department_doc_url(department_doc, format: :json)
