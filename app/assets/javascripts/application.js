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
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap
//= require turbolinks
//= require wice_grid
//= require select2
//= require select2_locale_zh-CN
//= require selectize
//= require activestorage
//= require third_party_js/select2totree
//= require third_party_js/papaparse
//= require third_party_js/bootstrap.file-input
//= require third_party_js/valid_admin

//= require custom_js/organizations
//= require custom_js/direct_uploads
//= require custom_js/doc_templates
//= require custom_js/departments
//= require custom_js/department_docs
//= require custom_js/main_cases
//= require custom_js/users
//= require custom_js/incoming_records

// nested form js
//= require cocoon

// weboffice
//= require weboffice/issetup
//= require weboffice/url

// 处理select2在turbolinks的bug
// 处理selectize在turbolinks中重复渲染的bug
$(document).on("turbolinks:before-cache", function() {
    $('.selectized').each(function(){
        if (this.selectize != undefined) {
            this.selectize.destroy()
        }
    });

    $('select.select2-hidden-accessible').select2('destroy');
});

// 处理组件在turbolinks中初始化中的bug
$(document).on('turbolinks:load', function () {
    $('select').selectize({
        valueField: 'id',
        labelField: 'name'
    });

    $('.datepicker').datepicker({
        format: 'yyyy-mm-dd',
        language: 'zh-CN',
        autoclose: true,
        todayHighlight: true
    });
});

// change select2 data via ajax, target select2 element data will refresh depend the change of original select2 element
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
                reloadSelectize(target_select, data[target_hash_key]);
            }); // post
    } else {
        target_select.empty();
    }
} // appendDataToSelect2

function reloadSelectize(select_elm, dataset, default_select_id = '') {
    var control = select_elm[0].selectize;
    control.clear('silent');
    control.clearOptions('silent');
    control.addOption(dataset, 'silent');
    control.setValue(default_select_id, 'silent');
}
