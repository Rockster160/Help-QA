// online_chat_list_count

$(document).ready(function() {
  App.chat_list = App.cable.subscriptions.create({
    channel: "ChatListChannel"
  }, {
    received: function(data) {
      console.log(data);
    }
  })
})
