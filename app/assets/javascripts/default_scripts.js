$(document).ready(function() {

  function showSelectedHash() {
    var withoutTag = window.location.hash;
    if (withoutTag.length != 0) {
      $(".highlight").removeClass("highlight");
      $(withoutTag).addClass("highlight");
    }
  }
  $(window).on("hashchange", showSelectedHash);
  showSelectedHash()

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

  $("[data-smooth-scroll]").click(function() {
    $("html, body").animate({
      scrollTop: $($(this).attr("href")).offset().top
    }, 300)
  })

})
