class DepartmentDocsController < ApplicationController
  layout 'system'
  before_action :set_department_doc, only: [:show, :edit, :update, :destroy]
  before_action :set_department, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  # GET /department_docs
  # GET /department_docs.json
  def index
    @department_docs = initialize_grid(@department.department_docs, per_page: 20, name: 'department_docs_grid')
  end

  # GET /department_docs/1
  # GET /department_docs/1.json
  def show
  end

  # GET /department_docs/new
  def new
    @department_doc = @department.department_docs.new
  end

  # GET /department_docs/1/edit
  def edit
  end

  # POST /department_docs
  # POST /department_docs.json
  def create
    @department_doc = @department.department_docs.new(department_doc_params)
    respond_to do |format|
      if @department_doc.save
        attach_doc

        format.html { redirect_to department_department_docs_url(@department), notice: '科室文档模板创建成功！' }
        format.json { render :show, status: :created, location: @department_doc }
      else
        format.html { render :new }
        format.json { render json: @department_doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /department_docs/1
  # PATCH/PUT /department_docs/1.json
  def update
    # 如果是更新文档内容，则需要删除之前的文档
    attachment_blob = @department_doc.attachment.blob

    respond_to do |format|
      if @department_doc.update(department_doc_params.to_h.merge(filename: attachment_blob.filename))
        # 删除之前的文档
        attachment_blob.purge
        # 添加文档
        attach_doc

        format.html { redirect_to department_department_docs_url(@department), notice: '科室文档模板更新成功！' }
        format.json { render :show, status: :ok, location: @department_doc }
      else
        format.html { render :edit }
        format.json { render json: @department_doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /department_docs/1
  # DELETE /department_docs/1.json
  def destroy
    @department_doc.destroy
    respond_to do |format|
      format.html { redirect_to department_department_docs_url(@department), notice: '科室文档模板摧毁成功！' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department_doc
      @department_doc = DepartmentDoc.find(params[:id])
    end

    def set_department
      @department = Department.find(params[:department_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_doc_params
      params.require(:department_doc).permit(:name,
                                             :doc_code,
                                             :case_stage,
                                             :check_archived,
                                             :check_archived_no,
                                             :attachment,
                                             :doc_template_id)
    end

    # 将系统的文档模板拷贝到当前科室中
    def attach_doc
      if !department_doc_params[:doc_template_id].blank?
        doc_template = DocTemplate.find(department_doc_params[:doc_template_id])
        @department_doc.attachment.attach io: StringIO.new(doc_template.attachment.download),
                                          filename: doc_template.attachment.filename,
                                          content_type: doc_template.attachment.content_type
        @department_doc.update(filename: doc_template.attachment.filename)
      end
    end
end
