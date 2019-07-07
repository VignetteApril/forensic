class EditOfficeOnlineController < ApplicationController
  layout 'edit_office'
  skip_before_action :authorize, :can
  skip_before_action :verify_authenticity_token

  def edit_office
    @file_path = params[:file_path]
    @department_doc = DepartmentDoc.find(params[:doc_id])
    @main_case
  end

  def save_doc
    doc_id = params[:doc_id]
    file = params[:docfile]

    doc = DepartmentDoc.find(doc_id)
    # 删除之前的文档
    doc.attachment.purge

    # 更新现在的文档
    doc.attachment.attach file

    render json: { status: 'ok' }
  end
end
