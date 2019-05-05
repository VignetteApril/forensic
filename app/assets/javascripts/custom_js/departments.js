$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'departments') {
        if ($('body').attr('data-action') === 'edit' || $('body').attr('data-action') === 'new') {

        }
    } // if
});