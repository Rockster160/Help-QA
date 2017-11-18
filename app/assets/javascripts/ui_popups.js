$(document).on("mouseenter", ".show-tooltip", function() {
  $(this).find(".tooltip").removeClass("hidden");
}).on("mouseleave", ".show-tooltip", function() {
  $(this).find(".tooltip").addClass("hidden");
});

$(document).on("mouseenter", ".dropdown-clickable", function(evt) {
  $(this).siblings(".dropdown-list").removeClass("hidden");
}).on("click tap touch touchstart", ".dropdown-clickable", function(evt) {
  if ($(this).siblings(".dropdown-list").hasClass("hidden")) {
    evt.preventDefault();
    $(this).siblings(".dropdown-list").removeClass("hidden");
    return false;
  }
}).on("mouseleave", ".dropdown-container", function() {
  $(".dropdown-list").addClass("hidden");
});
