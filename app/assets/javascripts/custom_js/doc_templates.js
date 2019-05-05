$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'doc_templates') {
        if ($('body').attr('data-action') === 'edit' || $('body').attr('data-action') === 'new') {
            $("#new_doc_template").submit(function(e){
                var doc_template_attachment = $("#doc_template_attachment")
                var file_length = doc_template_attachment['0']['files']['length']
                if (file_length == 0) {
                    doc_template_attachment.popover({ container: 'body',
                        placement: 'top',
                        content: '请选择文件',
                        trigger: 'focus'
                    });
                    doc_template_attachment.popover('show')
                    e.preventDefault();
                    return false
                }
            });
        }
    } // if
})