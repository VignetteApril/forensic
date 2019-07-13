json.extract! express_order, :id, :created_at, :updated_at
json.url express_order_url(express_order, format: :json)
