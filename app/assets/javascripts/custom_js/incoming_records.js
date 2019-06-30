$(document).on('turbolinks:load', function() {
    if ($('body').attr('data-controller') === 'incoming_records') {
        if ($('body').attr('data-action') === 'claim_record_index' || $('body').attr('data-action') === 'claim_record') {
            var main_case_select = $('#main_case');
            var payment_order_select = $('#incoming_record_payment_order_id');
            var request_url = window.location.origin + '/incoming_records/get_payment_order';

            main_case_select.selectize({
                valueField: 'id',
                labelField: 'name',
                onChange: function(value) {
                    appendDataToSelect2(request_url, value, payment_order_select, 'name', 'payment_orders');
                }
            });
        } // if
    } // if
})