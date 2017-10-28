$(".ctr-posts.act-show").ready(function() {

  App.posts = App.cable.subscriptions.create({
    channel: "RepliesChannel",
    channel_id: "replies_for_" + $(".post-container").attr("data-id")
  }, {
    connected: function() {
      updatePostsSinceLast()
    },
    disconnected: function() {},
    received: function(data) {
      updatePostsSinceLast()
    }
  })

  updatePostsSinceLast = function() {
    var url = window.location.href.split("?")[0]
    var last_post_timestamp = $(".posts-container .post-container").first().attr("data-timestamp")
    $.get(url, {since: last_post_timestamp}).success(function(data) {
      var prev_height = $(".posts-container").get(0).scrollHeight
      $(".posts-container").css({"max-height": prev_height})
      $(".posts-container").prepend(data)
      $(".posts-container").scrollTop($(".posts-container").get(0).scrollHeight)
      $(".posts-container").animate({
        scrollTop: 0
      }, {
        duration: 1000,
        complete: function() {
          $(".posts-container .post-container").slice(10).hide("fade", { direction: "down" }, 1000, function() {
            console.log("dead");
            $(this).remove()
            $(".posts-container").css({"max-height": ""})
          })
        }
      })
    })
  }

})
