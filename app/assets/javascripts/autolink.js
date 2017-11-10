$(".ctr-posts.act-show, .ctr-users.act-show").ready(function() {
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
  }

  autolinkTick()
  setInterval(autolinkTick, 500)
})

var url_regex = /.((http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)|http\:\/\/localhost:[0-9]{4})/g
var email_regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/g
var last_catch_url_regex = /^\w+(\.){2,}\w+$/g

shortToken = function() { return Math.random().toString(36).substr(2) }
randomToken = function() { return shortToken() + shortToken() + shortToken() }

$(document).on("click", ".hide-img", function(evt) {
  evt.preventDefault()
  $(this).parents(".link-preview").find(".link-preview-img").remove()
  $(this).remove()
  return false
})

loadImages = function() {
  $("[data-img-src]").each(function() {
    var $link = $(this), src = $link.attr("data-img-src")
    if (!src) { return }

    $link.removeAttr("data-img-src")

    var close_btn = $("<i>", {class: "fa fa-close"})
    var close_container = $("<div>", {class: "hide-img"}).html(close_btn)

    if (!src.match(url_regex)) { return }

    $("<img>", {
      src: src,
      class: "link-preview-img",
      load: function() {
        $link.prepend(this)
        $link.prepend(close_container)
      }
    })
  })
}

addCards = function(cards_data) {
  $(cards_data).each(function() {
    var card = this
    var $link = $('[data-loading-preview] > a[href="' + card.original_url + '"]'), $wrapper = $link.parent()
    $link.removeAttr("data-loading-preview")

    if (card.inline || $link.parents("[data-inline-links]").length > 0) {
      $link.html(card.html)
    } else {
      $link.html('<a rel="nofollow" href="' + card.url + '">[' + card.title + "]</a>")
      new_link = $(card.html)
      $link.closest("quote, .reply-content").append(new_link)
    }
  })
  $("[data-loading-preview]").each(function() {
    var $container = $(this)
    $container.html($container.text())
    $container.removeAttr("data-loading-preview")
  })
}

loadAllLinks = function() {
  if ($.active != 0) { return }
  var $links = $("[data-load-link]"), links_to_generate = []

  if ($links.length == 0) { return }


  $links.each(function() {
    var $link = $(this), link_href = $link.attr("data-load-link")
    $link.removeAttr("data-load-link").attr("data-loading-preview", "")

    if (email_regex.test(link_href)) { return }
    var max_link_length = 60
    var short_text_link = link_href.length > max_link_length ? (link_href.substr(0, max_link_length) + "...") : link_href

    $link.html('<a rel="nofollow" href="' + link_href + '"><i class="fa fa-spinner fa-spin"></i> ' + short_text_link + "</a>")

    links_to_generate.push(link_href)
  })

  $.ajax({
    url: "/url?" + $.param({urls: links_to_generate}),
    type: "GET",
    success: function(data) {
      addCards(data)
    },
    error: function(data) {
      console.log("Failed to load previews");
    }
  })
}

autolinkTick = function() {
  loadAllLinks()
  loadImages()
}
