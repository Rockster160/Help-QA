function showSelectedReply() {
  var withoutTag = window.location.hash;
  if (withoutTag.length != 0) {
    $(".highlight").removeClass("highlight");
    $(withoutTag).addClass("highlight");
  }
}

$(window).on("hashchange", showSelectedReply);
$(".ctr-posts.act-show").ready(function() {
  showSelectedReply();
})
