$(document).ready(function() {

  $('.js-clear-text-after-focus').focus(function() {
    if (!$(this).attr("data-has-focused")) {
      $(this).html("");
      $(this).attr("data-has-focused", true);
    }
  })

  $("textarea").keydown(function (e) {
    if (e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
      $(this).parents("form").submit()
    }
  });

})
