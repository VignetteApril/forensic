$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'main_cases') {
        if ($('body').attr('data-action') === 'edit' || $('body').attr('data-action') === 'new' || $('body').attr('data-action') === 'create' || $('body').attr('data-action') === 'update') {
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
            var request_url_org_and_user = window.location.origin + '/main_cases/organization_and_user';
            var organization_name = $('#main_case_organization_name');
            var user_name = $('#main_case_user_name');
            var wtr_phone = $('#main_case_wtr_phone');
            var organization_addr = $('#main_case_organization_addr');
            var user_id = $('#main_case_user_id');
            $('#import_user').click(function () {
                var user_select2 = $('#user_select');
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
                        wtr_phone.val(data.wtr_phone);
                        organization_addr.val(data.organization_addr);

                        province_select2.empty();
                        province_select2.selectize({
                            items: data.provinces
                        });
                        province_select2[0].selectize.setValue(data.current_province.id);

                        city_select2.empty();
                        city_select2.selectize({
                            items: data.cities
                        });
                        city_select2[0].selectize.setValue(data.current_city.id);

                        district_select2.empty();
                        district_select2.selectize({
                           items: data.districts
                        });
                        district_select2[0].selectize.setValue(data.current_district.id);
                    }
                });
            });

            // 根据用户填写的委托方信息和委托人信息
            var request_create_org_user = window.location.origin + '/main_cases/create_organization_and_user';
            $('#create_org_user').click(function () {
                $.ajax({
                    url: request_create_org_user,
                    type: 'POST',
                    data: {
                        wtr_phone: wtr_phone.val(),
                        user_name: user_name.val(),
                        organization_name: organization_name.val(),
                        organization_addr: organization_addr.val(),
                        province_id: province_select2.val(),
                        city_id: city_select2.val(),
                        district_id: district_select2.val()
                    },
                    dataType: 'script'
                })
                return;
            });

            // 科室和鉴定事项select2联动
            var department_select2 = $('#main_case_department_id');
            var main_case_matter_select2 = $('#main_case_matter');
            var main_case_case_type_select2 =  $('#main_case_case_type');
            var request_url_matters = window.location.origin + '/main_cases/matter_demands_and_case_types.json';
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
                        });

                        main_case_case_type_select2.empty();
                        main_case_case_type_select2.select2({
                            data: data.case_types
                        });
                    }
                });
            });

            // 单位和个人的radios button
            $('input[type=radio][name="main_case[appraised_unit_attributes][unit_type]"]').change(function() {
                if (this.value == 'unit') {
                    $('.hidden-fields').css('display','none');
                }
                else if (this.value == 'user') {
                    $('.hidden-fields').css('display','block');
                }
            });
        } // if

        if ($('body').attr('data-action') === 'index' || $('body').attr('data-action') === 'department_cases' || $('body').attr('data-action') === 'center_cases') {
            $(".clickable-row").click(function (e) {
                // 通过当前点击元素判断是否点击的是带有id的元素
                // 带有id的元素都具有原始的js事件，所有不应该触发跳转到编辑页面的js
                if (e.target.id == '') {
                    window.location = $(this).data("href");
                }
            });
        } // if
    } // if
})