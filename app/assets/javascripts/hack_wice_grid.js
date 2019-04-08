function init_wice_grid() {
  $(".expand-multi-select-icon").css("margin-top", "6px");
  $("tr.wg-filter-row input:not(.n_filter)").css('width', '100%')
  $(".custom-dropdown-container select").addClass("input-sm");
  // $(".wice-grid-title-row").css("background-color", "#e5e5e5");
  // $(".wg-filter-row").css("background-color", "#e5e5e5");
  
  first_th = $("tr.wice-grid-title-row th:first");
  $('.wg-filter-row').parent().find('tr').first().find('th').first().prepend("<span id='wice-grid-filter' style='cursor:pointer;'><i class='fa fa-filter'></i></span>&nbsp;&nbsp;");
  first_th.attr('scroll-time', '0');
  
  $('.wg-filter-row').css('display', 'none');
  $(".wice-grid-title-row").click(function() {
    if ($('.wg-filter-row').css('display') == 'none')
      $('.wg-filter-row').css('display', 'table-row');
    else
      $('.wg-filter-row').css('display', 'none');
  });

  $(".wice-grid-title-row").parent().parent().find("input:checkbox").parent().change(function() {
    if ($(this).find('input').is(":checked")) {
      $(this).parent().css('background-color', 'LightYellow');
    }else{
      $(this).parent().css('background-color', 'White');
    }
  });
}

function freeze_head(box_name, table_name, top_offset) {
  t = $("#"+box_name).scrollTop();
  
  if ($("#"+table_name+"-head").length > 0) {
    th = $("#"+table_name+"-head");
  }else{
    th = $("#"+table_name).clone();
    th.find("thead").attr('id', 'new-head');
    oldt = $("#"+table_name)
    oldt.find("thead").css("display", "none");
    oldt.css("margin-top", "-20px");
    
    th.attr("id", table_name+"-head");
    $("#"+table_name).before(th);
    th.find("tbody").css("display", "none");
    th.find("tfoot").css("display", "none");

    $("#new-head").children("tr.wice-grid-title-row").click(function() {
      if ($("#new-head").find('.wg-filter-row').css('display') != 'none') {
        $("#new-head").find('.wg-filter-row').css('display', 'none');
      }else{
        $("#new-head").find('.wg-filter-row').css('display', 'table-row');
      }
    });
  }
  th.css("position", "relative");
  
  if (t<100) {
    th.css("top", '0px');
  }else{
    th.css("display", "table");
    th.css("top", (t-top_offset)+'px');
  };
  
  $("#new-head").find("i.fa.fa-check-square-o").click(function() {
    oldt.find("input:checkbox").prop('checked', true);
    oldt.find("input:checkbox").parent().parent().css('background-color', 'LightYellow');
  });
  $("#new-head").find("i.fa.fa-square-o").click(function() {
    oldt.find("input:checkbox").removeAttr('checked');
    oldt.find("input:checkbox").parent().parent().css('background-color', 'White');
  });
}
