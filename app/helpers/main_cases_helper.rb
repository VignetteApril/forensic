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

    def get_distance_of_time(e)
    	item = ''
      case e.case_stage.to_sym

      when :pending
        item='已过' + distance_of_time_in_words(Time.now, e.created_at, scope: 'datetime.distance_in_words')

      when :add_material
        if e.identification_cycle.nil?
          item='请选择补充材料周期'
        else
          date_bool = Time.now <=> (e.created_at + e.material_cycle.days)
          date_pre_str = date_bool ? '还剩' : '已过'
          date_distance = distance_of_time_in_words(Time.now, e.created_at + e.material_cycle.days, scope: 'datetime.distance_in_words')
          if date_bool
             item = date_pre_str + date_distance
          else
             item = date_pre_str + date_distance
          end
        end

      when :filed
        if e.identification_cycle.nil?
          item = '请选择鉴定周期'
        else
          date_bool = Time.now <=> (e.acceptance_date + e.identification_cycle.days)
          date_pre_str = date_bool ? '还剩' : '已过'
          date_distance = distance_of_time_in_words(Time.now, e.acceptance_date + e.identification_cycle.days, scope: 'datetime.distance_in_words')
          if date_bool
            item = date_pre_str + date_distance
          else
            item = date_pre_str + date_distance
          end
        end
      end
    end
end
