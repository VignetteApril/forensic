# == Schema Information
#
# Table name: transfer_docs
#
#  id           :bigint           not null, primary key
#  name         :string
#  num          :integer
#  traits       :string
#  status       :string
#  receive_date :datetime
#  barcode      :string
#  main_case_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  doc_type     :string
#  unit         :string
#  serial_no    :integer          default(0)
#
require "test_helper"

describe TransferDoc do
  let(:transfer_doc) { TransferDoc.new }

  it "must be valid" do
    value(transfer_doc).must_be :valid?
  end
end
