received_sound = new Audio('https://www.soundjay.com/button/sounds/button-47.mp3');

$(".ctr-chat.act-chat").ready(function() {
  var currently_typing = {}
  var unread_count = 0

  $(window).on("click scroll focus", function() { unread_count = 0; updatePageTitleWithUnreads() })

  App.chat = App.cable.subscriptions.create({
    channel: "ChatChannel"
  }, {
    connected: function() {},
    disconnected: function() {},
    received: function(data) {
      if (data["message"] != undefined) {
        addMessages(data["message"])
      } else if (data["users"] != undefined) {
        $(".online-list").html(data["users"])
      } else if (data["ping"] != undefined) {
        this.perform("pong")
      } else {
        console.log("Unknown error: " + data)
      }
    },
    speak: function(msg) {
      return this.perform("speak", {
        message: msg
      })
    }
  })

  addMessages = function(messages_html) {
    $(".messages-container").append(messages_html)
    unread_count += $(messages_html).find(".message-container").length
    updatePageTitleWithUnreads()
    reorderMessages()
  }

  reorderMessages = function() {
    var messages = $(".messages-container .message-container")
    messages.sort(function(a, b) {
      return parseInt($(a).attr("data-timestamp")) - parseInt($(b).attr("data-timestamp"))
    })
    $(".messages-container").html(messages.slice(-1000))
  }

  updatePageTitleWithUnreads = function() {
    if (unread_count == 0) {
      document.title = "HelperNow Chat"
    } else if (unread_count == 1) {
      document.title = "(1 unread message) HelperNow Chat"
    } else {
      document.title = "(" + unread_count + " unread messages) HelperNow Chat"
    }
  }

  $(".chat-form").submit(function(evt) {
    evt.preventDefault()
    App.chat.speak($('input[name="chat-message"]').val())
    $('input[name="chat-message"]').val("")
    return false
  })

  $(".chat-form button").click(function() { $(this).parents("form").submit() })

})
