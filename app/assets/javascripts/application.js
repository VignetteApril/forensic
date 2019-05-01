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
