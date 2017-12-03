$(document).ready(function() {

  showSelectedHash = function() {
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

  $("textarea, input").keydown(function (e) {
    if (e.keyCode == 13 && (e.metaKey || e.ctrlKey)) {
      e.preventDefault()
      $(this).parents("form").submit()
      return false
    }
  });

  $("[data-smooth-scroll]").click(function() {
    $("html, body").animate({
      scrollTop: $($(this).attr("href")).offset().top
    }, 300)
  })

})
