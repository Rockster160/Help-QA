$(document).ready(function() {
  App.chat_list = App.cable.subscriptions.create({
    channel: "ChatListChannel"
  }, {
    connected: function() {
      $.get("/chat_list").success(function(data) {
        updateBlip(data.count)
      })
    },
    received: function(data) {
      updateBlip(data.count)
    }
  })

  updateBlip = function(count) {
    var count = parseInt(count) || 0
    $(".chat-list.blip").text(count)
    if (count > 0) {
      $(".chat-list.blip").removeClass("hidden")
    } else {
      $(".chat-list.blip").addClass("hidden")
    }
  }
})
