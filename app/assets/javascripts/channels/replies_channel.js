$(".ctr-posts.act-show").ready(function() {

  if ($("body.archive").length != 0) { return }

  var unread_replies = undefined
  var default_title = document.title
  $(window).on("click scroll focus", function() { unread_replies = 0; updatePageTitleWithUnreads() })

  App.replies = App.cable.subscriptions.create({
    channel: "RepliesChannel",
    channel_id: "replies_for_" + $(".post-container").attr("data-id")
  }, {
    connected: function() {
      updateRepliesSinceLast()
    },
    disconnected: function() {},
    received: function(data) {
      updateRepliesSinceLast()
    }
  })

  updatePageTitleWithUnreads = function() {
    if (isNaN(unread_replies)) { return unread_replies = 0 }
    if (unread_replies == 0) {
      document.title = default_title
    } else if (unread_replies == 1) {
      document.title = "(1 unread reply) " + default_title
    } else {
      document.title = "(" + unread_replies + " unread replies) " + default_title
    }
  }

  updateRepliesSinceLast = function() {
    var url = window.location.href.split("?")[0]
    var last_post_timestamp = $(".replies-container .pending-reply, .replies-container .reply-container").last().attr("data-timestamp")
    $.get(url, {since: last_post_timestamp}).success(function(data) {
      var prev_height = $(".replies-container").get(0).scrollHeight
      $(".replies-container").css({"max-height": prev_height})
      $(data).each(function() {
        if ($(this).attr("id") == undefined) { return }
        var existing_reply = $("#" + $(this).attr("id"))
        if (existing_reply.length > 0) {
          existing_reply.replaceWith(this)
        } else {
          debugger
          unread_replies += 1
          $(".replies-container").append(this)
        }
      })
      showSelectedHash()
      updatePageTitleWithUnreads()
      $(".replies-container").animate({
        "max-height": $(".replies-container").get(0).scrollHeight
      }, {
        duration: 1000,
        complete: function() {
          $(".reply-counter").html($(".reply-wrapper.countable").length)
          $(".replies-container").css({"max-height": ""})
        }
      })
    })
  }

  $(".new-reply-container form").submit(function(evt) {
    var $form = $(this)
    evt.preventDefault()
    $.post(this.action, $form.serializeArray()).success(function(data) {
      if (data.redirect) { window.location.href = data.redirect }
      if (data.errors.length != 0) {
        $(".reply-errors").html(data.errors.join("<br>"))
        $(".reply-errors").removeClass("hidden")
      } else {
        $(".reply-errors").addClass("hidden")
        $(".editing-reply").addClass("hidden")
        $form.find("textarea").val("")
        $form.find("input[name=id]").val("")
      }
    }).complete(function() {
      $form.find("input, button, textarea").prop("disabled", false)
    })
    $form.find("input, button, textarea").prop("disabled", true)
    return false
  })

})
