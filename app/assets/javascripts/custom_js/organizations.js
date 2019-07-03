$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'organizations') {
        if ($('body').attr('data-action') === 'edit' ||
            $('body').attr('data-action') === 'new' ||
            $('body').attr('data-action') === 'create' ||
            $('body').attr('data-action') === 'update' ) {
            var province_select2 = $("#organization_province_id");
            var city_select2 = $("#organization_city_id");
            var district_select2 = $("#organization_district_id");
            var request_url_cities = window.location.origin + '/areas/cities.json';
            var request_url_districts = window.location.origin + '/areas/districts.json';

            province_select2.selectize({
                valueField: 'id',
                labelField: 'name',
                onChange: function (value) {
                    appendDataToSelect2(request_url_cities, value, city_select2, 'name', 'cities');
                    district_select2[0].selectize.clear();
                    district_select2[0].selectize.clearOptions();
                }
            });

            city_select2.selectize({
                valueField: 'id',
                labelField: 'name',
                onChange: function (value) {
                    appendDataToSelect2(request_url_districts, value, district_select2, 'name', 'districts');
                }
            });

            district_select2.selectize({
                valueField: 'id',
                labelField: 'name'
            });
        } // if
    } // if
})