$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'main_cases') {
        if ($('body').attr('data-action') === 'edit' || $('body').attr('data-action') === 'new' || $('body').attr('data-action') === 'create' ) {
            // select2
            var province_select2 = $("#main_case_province_id");
            var city_select2 = $("#main_case_city_id");
            var district_select2 = $("#main_case_district_id");
            var request_url_cities = window.location.origin + '/areas/cities.json';
            var request_url_districts = window.location.origin + '/areas/districts.json';

            // listening the select2 change method
            province_select2.on("select2:select", function(e){
                // refresh project select2 element
                appendDataToSelect2(request_url_cities, e['currentTarget']['value'], city_select2, 'name', 'cities');
                district_select2.empty().trigger('change');
            });

            city_select2.on("select2:select", function(e){
                appendDataToSelect2(request_url_districts, e['currentTarget']['value'], district_select2, 'name', 'districts');
            });

            // 导入用户
            var request_url_org_and_user = window.location.origin + '/main_cases/organization_and_user.json';
            var organization_name = $('#main_case_organization_name');
            var user_name = $('#main_case_user_name');
            var organization_phone = $('#main_case_organization_phone');
            var organization_addr = $('#main_case_organization_addr');
            var user_id = $('#main_case_user_id');
            $('#import_user').click(function () {
                var user_select2 = $('#court_user_id');
                $.ajax({
                    url: request_url_org_and_user,
                    type: "GET",
                    data: {
                        'user_id': user_select2.val(),
                    },
                    dataType: 'json',
                    success: function (data) {
                        organization_name.val(data.organization_name);
                        user_name.val(data.user_name);
                        user_id.val(data.user_id);
                        organization_phone.val(data.organization_phone);
                        organization_addr.val(data.organization_addr);

                        province_select2.empty();
                        province_select2.select2({
                            data: data.provinces
                        });
                        province_select2.val(data.current_province.id).trigger('change');

                        city_select2.empty();
                        city_select2.select2({
                           data: data.cities
                        });
                        city_select2.val(data.current_city.id).trigger('change');

                        district_select2.empty();
                        district_select2.select2({
                           data: data.districts
                        });
                        district_select2.val(data.current_district.id).trigger('change');
                    }
                });
            });

            // 科室和鉴定事项select2联动
            var department_select2 = $('#main_case_department_id');
            var main_case_matter_select2 = $('#main_case_matter');
            var request_url_matters = window.location.origin + '/main_cases/matter_demands.json';
            department_select2.on("select2:select", function(e){
                $.ajax({
                    url: request_url_matters,
                    type: "GET",
                    data: {
                        'department_id': e['currentTarget']['value'],
                    },
                    dataType: 'json',
                    success: function (data) {
                        main_case_matter_select2.empty();
                        main_case_matter_select2.select2({
                            data: data.matters
                        })
                    }
                });
            });

            // 单位和个人的radios button
            $('input[type=radio][name="main_case[appraised_unit_attributes][unit_type]"]').change(function() {
                if (this.value == 'unit') {
                    $('#hidden-fields').css('display','none');
                }
                else if (this.value == 'user') {
                    $('#hidden-fields').css('display','block');
                }
            });
        } // if
    } // if
})