// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require popper
//= require bootstrap
//= require jquery_ujs
//= require jquery-ui
//= require turbolinks
//= require wice_grid
//= require bootstrap-datepicker
//= require select2
//= require select2_locale_zh-CN
//= require select2totree
//= require papaparse
//= require bootstrap.file-input
//= require tabler/tabler
//= require tabler/vendors/circle-progress.min
//= require tabler/core
//= require selectize

//= require custom_js/organizations
//= require custom_js/direct_uploads
//= require custom_js/doc_templates
//= require custom_js/departments
//= require custom_js/department_docs


// 处理select2在turbolinks的bug
$(document).on("turbolinks:before-cache", function() {
    $('select.select2-hidden-accessible').select2('destroy');
});

$(document).on('turbolinks:load', function () {
    $('select').select2({
        theme: 'bootstrap'
    });

    $('.datepicker').datepicker({
        format: 'yyyy-mm-dd',
        language: 'zh-CN',
        autoclose: true,
        todayHighlight: true
    });
});

// change select2 data via ajax, target select2 element data will refresh depend the change of orginal select2 element
// request_url:               the method will send the ajax post request to this url, and get data from the action
// selected_id:               orginal select2 element selected option id
// target_select:             the target select2 element, we will refresh the data of target select2 element
// column_name:               target select2 element option name, it depend on the data you get
// target_hash_key:           the key you access data from action, it depend on the data you get
// orginal_select2_element:   the orginal select2 element name
function appendDataToSelect2(request_url, selected_id, target_select, column_name, target_hash_key, orginal_select2_element = '') {
    if (selected_id) {
        // send the ajax post request to backend
        $.post(request_url,
            {
                id: selected_id,
            },
            function(data, status){
                // empty projects select2 element
                target_select.empty().trigger('change');
                // append empty option element to select2
                target_select.append(document.createElement("option"));
                // append date to the empty select2 element
                $.each(data[target_hash_key],  function(i, value){
                    var tempOption = document.createElement("option");
                    tempOption.value = value.id;
                    tempOption.innerHTML = value[column_name];
                    target_select.append(tempOption);
                }); // each
            }); // post
    } else {
        target_select.empty().trigger('change');
    }
} // appendDataToSelect2
