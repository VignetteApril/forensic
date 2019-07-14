class AddReporterToExpressOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :express_orders, :reporter, :string
  end
end
