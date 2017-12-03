$(document).ready(function() {
  App.chat_list = App.cable.subscriptions.create({
    channel: "ChatListChannel"
  }, {
    connected: function() {
      if (parseInt($(".chat-list.blip").text()) > 0) {
        $(".chat-list.blip").removeClass("hidden")
      }
    },
    received: function(data) {
      $(".chat-list.blip").text(data.count)
    }
  })
})
