received_sound = new Audio("https://www.soundjay.com/button/sounds/button-47.mp3")

$(".ctr-chat.act-chat").ready(function() {
  var currently_typing = {}
  var unread_count = 0
  var auto_scroll = true
  var user_scrolling = true

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
      if (data["message"] != undefined) {
        addMessage(data["message"])
      } else if (data["removed"] != undefined) {
        removeId(data["removed"])
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

  highlightCurrentUsername = function(html) {
    if (current_username.length == 0) { return }
    $(".message-container .body p").each(function() {
      $(this).html($(this).html().replace("@" + current_username, '<span class="highlight">@' + current_username + '</span>'))
    })
  }

  addMessagesByHTML = function(messages_html) {
    if ($(messages_html).length > 0) {
      received_sound.play()
      $(".messages-container").append(messages_html)
      unread_count += $(messages_html).length
      updatePageTitleWithUnreads()
      reorderMessages()
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

  reorderMessages = function() {
    var messages = $(".messages-container .message-container")
    messages.sort(function(a, b) {
      return parseInt($(a).attr("data-timestamp")) - parseInt($(b).attr("data-timestamp"))
    })
    var message_ids = messages.map(function() { return $(this).attr("data-message-id") }).toArray()
    messages = messages.filter(function(index, message) { return message_ids.indexOf($(message).attr("data-message-id")) === index })
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
  scrollTo()
  scrollToSelectedMessage()
  highlightCurrentUsername($(".messages-container"), current_username)

})
