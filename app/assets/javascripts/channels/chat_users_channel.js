// online_chat_list_count
// This is to show the number of users currently in Chat globally

$(document).ready(function() {
  App.chat_list = App.cable.subscriptions.create({
    channel: "ChatListChannel"
  }, {
    received: function(data) {
      console.log(data);
    }
  })
})
