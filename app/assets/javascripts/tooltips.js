$(document).on("mouseenter", ".show-tooltip", function() {
  $(this).find(".tooltip").removeClass("hidden");
}).on("mouseleave", ".show-tooltip", function() {
  $(this).find(".tooltip").addClass("hidden");
})
