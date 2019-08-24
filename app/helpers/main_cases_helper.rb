module MainCasesHelper
    def department_collection
        Department.all.map { |department| [department.name, department.id] }
    end

    def case_stages_collection
        MainCase.case_stages.map { |key, value| [ MainCase::CASE_STAGE_MAP[key.to_sym], value ] }
    end

    def financial_stage_collection
        MainCase.financial_stages.map { |key, value| [ MainCase::FINANCIAL_STAGE_MAP[key.to_sym], value ] }
    end

    def get_distance_of_time(main_case)
      case main_case.case_stage.to_sym
      when :pending
        content_tag :div, class: "text-success" do
          '距离登记已过' + distance_of_time_in_words(Time.now, main_case.created_at, scope: 'datetime.distance_in_words')
        end
      when :add_material
        if main_case.material_cycle.nil?
          '请选择补充材料周期'
        else
          date_bool = Time.now <=> (main_case.created_at + main_case.material_cycle.days)
          date_pre_str = date_bool > 0 ?  '距补充材料规定日期已过' : '距离补充材料到期还剩'
          date_distance = distance_of_time_in_words(Time.now, main_case.created_at + main_case.material_cycle.days, scope: 'datetime.distance_in_words')
          if date_bool
            content_tag :div, class: "text-warning" do
              date_pre_str + date_distance
            end
          else
            content_tag :div, class: "text-muted" do
              date_pre_str + date_distance
            end
          end
        end
      else
        if main_case.identification_cycle.nil?
          '请选择鉴定周期'
        else
          date_bool = Time.now <=> (main_case.acceptance_date + main_case.identification_cycle.days)
          date_pre_str = date_bool > 0 ?  '结案已过' : '距离结案还剩'
          date_distance = distance_of_time_in_words(Time.now, main_case.acceptance_date + main_case.identification_cycle.days, scope: 'datetime.distance_in_words')
          if date_bool
            content_tag :div, class: "text-danger" do
              date_pre_str + date_distance
            end
          else
            content_tag :div, class: "text-muted" do
              date_pre_str + date_distance
            end
          end
        end
      end
    end
end
