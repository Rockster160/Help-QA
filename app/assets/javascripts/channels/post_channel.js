$(".ctr-index.act-index").ready(function() {

  App.notifications = App.cable.subscriptions.create({
    channel: "PostChannel"
  }, {
    connected: function() {
      updateNotifications()
    },
    disconnected: function() {},
    received: function(data) {
      if (data["message"] != undefined) {
        addFlashNotice(data["message"])
      }
      updateNotifications()
    }
  })

  updateNotifications = function() {
    $.get(notifications_url).success(function(data) {
      $("#notifications-notices").text(data.notices)
      $("#notifications-shouts").text(data.shouts)
      $("#notifications-invites").text(data.invites)
    })
  }

})
