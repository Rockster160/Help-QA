$(".ctr-posts.act-show").ready(function() {
  function onPageLoaded() {
    var jqxhrs = [];

    $(window).bind("beforeunload", function (event) {
      $.each(jqxhrs, function (idx, jqxhr) {
        if (jqxhr) { jqxhr.abort(); }
      });
    });

    function registerJqxhr(event, jqxhr, settings) {
      jqxhrs.push(jqxhr);
    }

    function unregisterJqxhr(event, jqxhr, settings) {
      var idx = $.inArray(jqxhr, jqxhrs);
      jqxhrs.splice(idx, 1);
    }

    $(document).ajaxSend(registerJqxhr);
    $(document).ajaxComplete(unregisterJqxhr);
  };

  setTimeout(parseLinks, 1000)
})

var url_regex = /.(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g
var email_regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

shortToken = function() { return Math.random().toString(36).substr(2) }
randomToken = function() { return shortToken() + shortToken() + shortToken() }

$(document).on("click", ".hide-img", function(evt) {
  evt.preventDefault()
  $(this).parents(".link-preview").find(".link-preview-img").remove()
  $(this).remove()
  return false
})

loadLinkImages = function(link_container) {
  link_container.find("[data-img-src]").each(function() {
    var link = $(this), src = link.attr("data-img-src")
    link.removeAttr("data-img-src")

    var close_btn = $("<i>", {class: "fa fa-close"})
    var close_container = $("<div>", {class: "hide-img"}).html(close_btn)

    if (!src.match(url_regex)) { return }

    $("<img>", {
      src: src,
      class: "link-preview-img",
      load: function() {
        link.prepend(this)
        link.prepend(close_container)
      }
    })
  })
}

loadNextLink = function() {
  var $link = $("[data-load-link]").first()

  if ($link.length == 0) { return }

  $link.removeAttr("data-load-link")
  var link_container = $link, link = $link.html()

  if (email_regex.test(link)) { return }
  var max_link_length = 60
  var short_text_link = link.length > max_link_length ? (link.substr(0, max_link_length) + "...") : link

  $link.html("<a href=\"" + link + "\">" + short_text_link + "</a>")

  $.ajax({
    url: "/url",
    type: "GET",
    timeout: 5000,
    data: {url: link},
    success: function(data) {
      link_container.html(data)
      loadLinkImages(link_container)
    },
    error: function(data) {
      console.log("Failed to load preview:", link);
    }
  })
}

parseLinks = function() {
  $(".reply-content").each(function() {
    var new_body = $(this).html()

    new_body = new_body.replace(/\<a.*?\<\/a\>/, function(found) {
      return found
    })

    new_body = new_body.replace(url_regex, function(found) {
      var pre_char = found.charAt(0)
      found = found.substr(1)

      if (pre_char === "\"") { return pre_char + found }
      if (pre_char === "\\") { return found }

      return pre_char + "<span data-load-link>" + found + "</span>"
    })

    $(this).html(new_body)
  })
}

tick = function() {
  loadNextLink()
}
setInterval(tick, 500)
