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
//= require bootstrap-datepicker
//= require wice_grid
//= require select2
//= require select2_locale_zh-CN
//= require selectize
//= require activestorage
//= require third_party_js/select2totree
//= require third_party_js/papaparse
//= require third_party_js/bootstrap.file-input
//= require third_party_js/valid_admin
//= require third_party_js/webcam.js

//= require custom_js/organizations
//= require custom_js/direct_uploads
//= require custom_js/doc_templates
//= require custom_js/department_docs
//= require custom_js/main_cases
//= require custom_js/users

// nested form js
//= require cocoon

// weboffice
//= require weboffice/issetup
//= require weboffice/url
//= require highcharts
//= require html2canvas.js
//= require exporting
//= require offline-exporting
//= require export-csv.js


$(document).ready(function () {
    $('select').selectize({
        valueField: 'id',
        labelField: 'name'
    });
    Highcharts.setOptions({
        lang:{
           contextButtonTitle:"图表导出菜单",
           decimalPoint:".",
           downloadJPEG:"下载JPEG图片",
           downloadPDF:"下载PDF文件",
           downloadPNG:"下载PNG文件",
           downloadSVG:"下载SVG文件",
           downloadCSV:"下载CSV文件",
           downloadXLS:"下载XLS文件",
           viewFullscreen:"全屏浏览",
           viewData:"查看数据",
           drillUpText:"返回 {series.name}",
           loading:"加载中",
           months:["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"],
           noData:"没有数据",
           numericSymbols: [ "千" , "兆" , "G" , "T" , "P" , "E"],
           printChart:"打印图表",
           resetZoom:"恢复缩放",
           resetZoomTitle:"恢复图表",
           shortMonths: [ "Jan" , "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" , "Sep" , "Oct" , "Nov" , "Dec"],
           thousandsSep:",",
           weekdays: ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六","星期天"]
        }
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

function set_default_selected(select_elm, value) {
    if (select_elm[0] != undefined) {
        var control = select_elm[0].selectize;
        control.setValue(value, 'silent');
    };
}

function digitUppercase(n) {
    var fraction = ['角', '分'];
    var digit = [
        '零', '壹', '贰', '叁', '肆',
        '伍', '陆', '柒', '捌', '玖'
    ];
    var unit = [
        ['元', '万', '亿'],
        ['', '拾', '佰', '仟']
    ];
    var head = n < 0 ? '欠' : '';
    n = Math.abs(n);
    var s = '';
    for (var i = 0; i < fraction.length; i++) {
        s += (digit[Math.floor(n * 10 * Math.pow(10, i)) % 10] + fraction[i]).replace(/零./, '');
    }
    s = s || '整';
    n = Math.floor(n);
    for (var i = 0; i < unit[0].length && n > 0; i++) {
        var p = '';
        for (var j = 0; j < unit[1].length && n > 0; j++) {
            p = digit[n % 10] + unit[1][j] + p;
            n = Math.floor(n / 10);
        }
        s = p.replace(/(零.)*零$/, '').replace(/^$/, '零') + unit[0][i] + s;
    }
    return head + s.replace(/(零.)*零元/, '元')
        .replace(/(零.)+/g, '零')
        .replace(/^整$/, '零元整');
}
