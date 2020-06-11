class EditOfficeOnlineController < ApplicationController
  layout 'edit_office'
  skip_before_action :authorize, :can
  skip_before_action :verify_authenticity_token

  def edit_office

    @department_doc = DepartmentDoc.find_by_id(params[:doc_id]) || DocTemplate.find_by_id(params[:doc_id])
    @file_path = url_for(@department_doc.attachment)

    # 只有在案件里的doc才会执行替换操作，因为非案件的doc，根本获取不到案件信息
    # 非案件的只提供在线编辑并保存的功能
    if @department_doc.instance_of?(DepartmentDoc) && @department_doc.docable.instance_of?(MainCase)
      @main_case = @department_doc.docable
      @province_name = Area.find_by_id(@main_case.province_id).try(:name)
      @city_name = Area.find_by_id(@main_case.city_id).try(:name)
      @district_name = Area.find_by_id(@main_case.district_id).try(:name)
      @case_matter = JSON.parse(@main_case.matter).join(',')
      if !@main_case.appraised_unit.nil?
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

      # 移交材料语句
      # 1、name xx unit 2、name xx unit这种形式，插入到@#移交材料#@占位符中
      if !@main_case.transfer_docs.empty?
        @transfer_docs = @main_case.transfer_docs.map do |transfer_doc|
          base_string = "收到#{transfer_doc.name}#{transfer_doc.num}#{transfer_doc.unit}，"
          base_string.prepend("于#{transfer_doc.receive_date.strftime('%Y年%m月%d日')}") unless transfer_doc.receive_date.nil?
          base_string.prepend("#{transfer_doc.serial_no}、") unless transfer_doc.serial_no.nil?
          base_string << "类型为：#{transfer_doc.doc_type}，" unless transfer_doc.doc_type.nil?
          base_string << "性状为：#{transfer_doc.traits}，" unless transfer_doc.traits.nil?
          base_string << "状态为：#{transfer_doc.status}。" unless transfer_doc.status.nil?
        end.join
      else
        @transfer_docs = '无移交材料'
      end

      @barcode_path = url_for(@main_case.barcode_image)
    end
  end

  def save_doc
    doc_id = params[:doc_id]
    file = params[:docfile]

    doc = DepartmentDoc.find_by_id(doc_id) || DocTemplate.find_by_id(params[:doc_id])
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
    send_file("#{Rails.root}/public/WebOffice.rar")
  end

  def download_doc
    doc_id = params[:doc_id]
    doc = DepartmentDoc.find_by_id(doc_id) || DocTemplate.find_by_id(doc_id)
    doc_path = url_for(doc.attachment)
    redirect_to doc_path and return
  end
end
