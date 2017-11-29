$(document).on("mouseenter", ".show-tooltip", function() {
  $(this).find(".tooltip").removeClass("hidden")
}).on("mouseleave", ".show-tooltip", function() {
  $(this).find(".tooltip").addClass("hidden")
})

$(document).on("mouseenter", ".dropdown-clickable", function(evt) {
  $(this).siblings(".dropdown-list").removeClass("hidden")
}).on("click tap touch touchstart", function(evt) {
  var $originalTarget = $(evt.originalEvent.target)
  if ($originalTarget.hasClass("dropdown-container") || $originalTarget.parents(".dropdown-container").length > 0) {
    if ($originalTarget.siblings(".dropdown-list").hasClass("hidden")) {
      evt.preventDefault()
      $originalTarget.siblings(".dropdown-list").removeClass("hidden")
      return false
    }
  } else {
    $(".dropdown-list").addClass("hidden")
  }
}).on("mouseleave", ".dropdown-container", function() {
  $(".dropdown-list").addClass("hidden")
})
