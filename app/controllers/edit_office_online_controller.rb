class EditOfficeOnlineController < ApplicationController
  layout 'edit_office'
  skip_before_action :authorize, :can
  skip_before_action :verify_authenticity_token

  def edit_office
    @file_path = params[:file_path]
    @department_doc = DepartmentDoc.find(params[:doc_id])
    @main_case = @department_doc.docable
    @province_name = Area.find(@main_case.province_id).try(:name)
    @city_name = Area.find(@main_case.city_id).try(:name)
    @district_name = Area.find(@main_case.district_id).try(:name)
    @case_matter = JSON.parse(@main_case.matter).join(',')
    @appraised_unit_type = AppraisedUnit::UNIT_TYPE_MAP[@main_case.appraised_unit.unit_type.to_sym]
    @appraised_gender = if @main_case.appraised_unit.gender
                          AppraisedUnit::GENDER_MAP[@main_case.appraised_unit.gender.to_sym]
                        else
                          '空值'
                        end
    @appraised_id_type = if @main_case.appraised_unit.id_type
                            AppraisedUnit::ID_TYPE[@main_case.appraised_unit.id_type.to_sym]
                         else
                           '空值'
                         end
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

  # 通过department_doc id获取到当前文档的绝对路径，并传递给智能窗
  def get_doc_url
    doc = DepartmentDoc.find(params[:doc_id])
    url = url_for(doc.attachment)

    respond_to do |format|
      format.json { render json: { url: url } }
    end
  end

  # 下载控件
  def download_weboffice
    send_file("#{Rails.root}/public/webOffice.rar")
  end
end
