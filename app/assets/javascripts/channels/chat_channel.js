received_sound = new Audio("https://www.soundjay.com/button/sounds/button-47.mp3")
// https://www.soundjay.com/mechanical/sounds/multi-plier-open-1.mp3
// https://www.soundjay.com/mechanical/sounds/camera-shutter-click-08.mp3
// https://www.soundjay.com/misc/sounds/whip-whoosh-03.mp3
// https://www.soundjay.com/misc/sounds/briefcase-lock-6.mp3
// https://www.soundjay.com/misc/sounds/coin-drop-5.mp3

$(".ctr-chat.act-chat").ready(function() {
  var currently_typing = {}
  var unread_count = 0
  var auto_scroll = true
  var user_scrolling = true
  var guest_token
  var ignored_ids = []

  $(window).on("click scroll focus", function() { unread_count = 0; updatePageTitleWithUnreads() })

  App.chat = App.cable.subscriptions.create({
    channel: "ChatChannel"
  }, {
    connected: function() {
      var url = window.location.href.split("?")[0]
      $.get(url, {since: $(".message-container").last().attr("data-timestamp")}).success(addMessagesByHTML)
      $(".connection-trouble").addClass("hidden")
    },
    disconnected: function() {
      $(".connection-trouble").removeClass("hidden")
    },
    received: function(data) {
      guest_token = data["token"]
      this.perform("pong", { guest_token: guest_token })
      if (data["message"] != undefined) {
        addMessage(data["message"])
      } else if (data["removed"] != undefined) {
        removeId(data["removed"])
      } else if (data["users"] != undefined) {
        updateOnlineList(data["users"])
      } else if (data["ping"] != undefined) {
        // No op, the pong takes care of this
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

  updateOnlineList = function(users_html) {
    $(".online-list").html(users_html)
  }

  highlightCurrentUsername = function(html) {
    if (current_username.length == 0) { return }
    $(".message-container .body p").each(function() {
      $(this).html($(this).html().replace("@" + current_username, '<span class="highlight">@' + current_username + '</span>'))
    })
  }

  addMessagesByHTML = function(messages_html) {
    if ($(messages_html).length > 0) {
      var $new_messages = $(messages_html)
      $(messages_html).each(function() {
        var author_id = $(this).attr("data-author-id")
        if (current_userid != author_id) {
          if (ignored_ids.indexOf(author_id) >= 0) {
            this.remove()
            // TODO: Test me
          } else {
            received_sound.play()
            unread_count += $(messages_html).length
          }
        }
      })
      $(".messages-container").append(messages_html)
      updatePageTitleWithUnreads()
      if (auto_scroll) { scrollTo(300) }
    }
  }

  addMessage = function(message_id) {
    var url = window.location.href.split("?")[0]
    $.get(url, {id: message_id}).success(addMessagesByHTML)
  }

  removeId = function(removed_id) {
    $("[data-message-id=" + removed_id + "]").remove()
  }

  updatePageTitleWithUnreads = function() {
    if (unread_count == 0) {
      document.title = "Help-QA Chat"
    } else if (unread_count == 1) {
      document.title = "(1 unread message) Help-QA Chat"
    } else {
      document.title = "(" + unread_count + " unread messages) Help-QA Chat"
    }
  }

  scrollTo = function(speed, scroll_location) {
    var container = $(".messages-container")
    user_scrolling = false
    container.animate({
      scrollTop: scroll_location || container.get(0).scrollHeight
    }, {
      duration: speed || 0,
      complete: function() { user_scrolling = true }
    })
  }

  scrollToSelectedMessage = function() {
    if (params.message) {
      var selected_message = $(".message-container[data-message-id=" + params.message + "]")
      if (selected_message.length > 0) {
        scrollTo(300, $(".message-container.highlight").get(0).offsetTop - $(".messages-container").get(0).offsetTop)
      }
    }
  }

  $(".chat-form").submit(function(evt) {
    evt.preventDefault()
    App.chat.speak($('input[name="chat-message"]').val())
    $('input[name="chat-message"]').val("")
    return false
  })

  $(".chat-form button").click(function() { $(this).parents("form").submit() })

  $(".messages-container").scroll(function() {
    if (user_scrolling) {
      auto_scroll = $(this).scrollTop() + $(this).innerHeight() >= this.scrollHeight
    }
  })

  $(".mute").click(function() {
    $(this).find(".hover-icon").toggleClass("hidden")
  })

  scrollTo()
  scrollToSelectedMessage()
  highlightCurrentUsername($(".messages-container"), current_username)
  updateOnlineList()

})
