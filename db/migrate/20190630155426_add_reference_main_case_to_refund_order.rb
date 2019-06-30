class AddReferenceMainCaseToRefundOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :refund_orders, :main_case, index: true,foreign_key: true
    remove_reference :refund_orders, :payment_order, index: true
  end
end
