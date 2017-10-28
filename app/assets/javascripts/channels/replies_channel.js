$(".ctr-posts.act-show").ready(function() {

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

  updateRepliesSinceLast = function() {
    var url = window.location.href.split("?")[0]
    var last_post_timestamp = $(".replies-container .pending-reply, .replies-container .reply-container").last().attr("data-timestamp")
    $.get(url, {since: last_post_timestamp}).success(function(data) {
      var prev_height = $(".replies-container").get(0).scrollHeight
      $(".replies-container").css({"max-height": prev_height})
      $(".replies-container").append(data)
      $(".replies-container").animate({ "max-height": $(".replies-container").get(0).scrollHeight }, 1000)
    })
  }

})
