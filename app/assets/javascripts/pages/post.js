$(".ctr-posts.act-show").ready(function() {

  $(document).on("click", ".quote-reply", function(evt) {
    evt.preventDefault()
    var reply_text = $(this).parents(".reply-container").find(".reply-content").last().attr("data-original-content")
    var author_name = $(this).parents(".reply-container").find(".reply-username").html()
    $("#reply_body").focus()
    $("#reply_body").val($("#reply_body").val() + "[quote " + author_name + "]" + reply_text + "[/quote]")
    return false
  })

  $(document).on("click", ".edit-reply", function(evt) {
    evt.preventDefault()
    var $form = $("#new-reply-form")

    var reply_id = $(this).attr("data-reply-id")
    $form.find("input[name=id]").val(reply_id)

    var reply_text = $(this).parents(".reply-container").find(".reply-content").last().attr("data-original-content")
    $form.find("#reply_posted_anonymously").prop("checked", $(this).parents(".reply-container").attr("data-anonymous") == "true")

    $(".editing-reply").removeClass("hidden")
    $("#reply_body").val(reply_text)
    $("#reply_body").focus()
    return false
  })

  $(document).on("click", ".cancel-edit", function(evt) {
    evt.preventDefault()
    var $form = $("#new-reply-form")
    $form.find("input[name=id]").val("")
    $(".editing-reply").addClass("hidden")
    return false
  })

  $(document).on("click", ".toggle-reply-display", function() {
    var $container = $(this).parents(".pending-reply").siblings(".reply-container")
    $container.slideToggle()
  })

})


// Test unauthed users cannot edit other replies / non logged in users don't cause issues
