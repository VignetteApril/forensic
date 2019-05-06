$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'department_docs') {
        if ($('body').attr('data-action') === 'edit' || $('body').attr('data-action') === 'new') {
            var template_select = $('#department_doc_doc_template_id');
            var attachment_upload = $('.attachment_upload');
            var upload_attachment = $('#department_doc_attachment');

            // 页面渲染完成后就检查当前select2元素是否选中了值
            if (template_select.val() != '') {
                attachment_upload.addClass('d-none');
            } else {
                attachment_upload.removeClass('d-none');
            };

            // 根据select2元素选中的值，动态渲染上传按钮
            template_select.on("select2:select", function(e){
                if (e['currentTarget']['value'] == '') {
                    attachment_upload.removeClass('d-none');
                } else {
                    attachment_upload.addClass('d-none');
                    upload_attachment.val('');
                }
            });
        }
    } // if
});