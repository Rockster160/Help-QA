$(".ctr-posts.act-show, .ctr-users.act-show, .ctr-shouts").ready(function() {
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

var url_regex = /.((http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~;#?&//=]*)|http\:\/\/localhost:[0-9]{4})/g
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
    var $link = $('[data-loading-preview][href="' + card.original_url + '"]')
    var no_preview = $link.attr("data-loading-preview") == "no"
    $link.removeAttr("data-loading-preview")
    if (card.invalid_url) { return $link.replaceWith(card.original_url) }
    if (no_preview && !card.inline) { return $link.html($link.first().text()) }

    if (card.inline || $link.parents("[data-inline-links]").length > 0) {
      $link.html(card.html)
    } else {
      $link.html('<a rel="nofollow" target="_blank" href="' + card.url + '">[' + card.title + "]</a>")
      new_link = $(card.html)
      $link.closest("quote, .reply-content, .shout-body").append(new_link)
    }
  })
}

function chunkArray(myArray, chunk_size){
  var results = [];
  while (myArray.length) {
    results.push(myArray.splice(0, chunk_size));
  }

  return results;
}

loadAllLinks = function() {
  if ($.active != 0) { return }
  var $links = $("[data-load-preview]"), links_to_generate = []

  if ($links.length == 0) { return }

  $links.each(function() {
    var $link = $(this)
    links_to_generate.push($link.attr("href"))

    $link.attr("data-loading-preview", $link.attr("data-load-preview")).removeAttr("data-load-preview")
    $link.prepend('<i class="fa fa-spinner fa-spin"></i>')
  })

  var chunkedLinkGroups = chunkArray(links_to_generate, 3)
  for (var i=0;i<chunkedLinkGroups.length;i++) {
    var chunkedLinks = chunkedLinkGroups[i]

    $.ajax({
      url: "/url?" + $.param({urls: chunkedLinks}),
      type: "GET",
      success: function(data) {
        addCards(data)
      },
      error: function(data) {
        console.log("Failed to load previews");
      }
    })
  }

}

autolinkTick = function() {
  loadAllLinks()
  loadImages()
}
