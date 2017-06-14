$(document).on("mouseenter", ".show-tooltip", function() {
  $(this).find(".tooltip").removeClass("hidden");
}).on("mouseleave", ".show-tooltip", function() {
  $(this).find(".tooltip").addClass("hidden");
});

$(document).on("click tap mouseenter", ".dropdown-clickable", function(evt) {
  evt.preventDefault();
  $(this).siblings(".dropdown-list").removeClass("hidden");
  return false;
}).on("mouseleave", ".dropdown-container", function() {
  $(".dropdown-list").addClass("hidden");
});
