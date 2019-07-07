$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'incoming_records') {
        if ($('body').attr('data-action') === 'claim_record_index' || $('body').attr('data-action') === 'claim_record') {

        } // if
    } // if
})