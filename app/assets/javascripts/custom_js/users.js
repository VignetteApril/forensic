if ($('body').attr('data-controller') === 'users') {
    if ($('body').attr('data-action') === 'edit' ||
        $('body').attr('data-action') === 'new' ||
        $('body').attr('data-action') === 'update' ||
        $('body').attr('data-action') === 'create') {
        var city_select2 = $("#user_city_id");
        var district_select2 = $("#user_district_id");
        var request_url_districts = window.location.origin + '/areas/districts.json';

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
