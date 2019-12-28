module MainCasesHelper
    def department_collection
        Department.all.map { |department| [department.name, department.name] }
    end

    def case_stages_collection
        MainCase.case_stages.map { |key, value| [ MainCase::CASE_STAGE_MAP[key.to_sym], value ] }
    end

    def financial_stage_collection
        MainCase.financial_stages.map { |key, value| [ MainCase::FINANCIAL_STAGE_MAP[key.to_sym], value ] }
    end

    def get_distance_of_time(main_case)
        main_case.distance_of_time
    end
end
