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

    def province_collection
      Area.roots.map { |province| [province.name, province.id] }
    end

    def payment_method_collection
        ['现金收款', '银行汇款', '其他'].map { |item| [item, item] }
    end
end
