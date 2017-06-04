$('.ctr-index.act-index').ready(function() {

  $('.js-clear-text-after-focus').focus(function() {
    if (!$(this).attr("data-has-focused")) {
      $(this).html("");
      $(this).attr("data-has-focused", true);
    }
  })

})
