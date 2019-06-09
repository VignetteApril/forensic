$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'users') {
        if ($('body').attr('data-action') === 'edit' || $('body').attr('data-action') === 'new') {
            var city_select2 = $("#user_city_id");
            var district_select2 = $("#user_district_id");
            var request_url_districts = window.location.origin + '/areas/districts.json';

            city_select2.on("select2:select", function(e){
                appendDataToSelect2(request_url_districts, e['currentTarget']['value'], district_select2, 'name', 'districts');
            });
        } // if
    } // if
})