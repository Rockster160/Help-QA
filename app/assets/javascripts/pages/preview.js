$(".ctr-posts.act-show").ready(function() {

  $(".preview-reply").click(function(evt) {
    evt.preventDefault()
    $preview = $(".preview-container")
    $preview.html("Loading...")

    $.get($preview.attr("data-url"), { body: $(".reply-field").val() }).success(function(data) {
      $preview.html($("<div>", { class: "reply-wrapper" }).html(data))
    })
  })

})
