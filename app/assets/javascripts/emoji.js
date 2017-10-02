$(document).ready(function() {

  addEmojiToLoader = function(name, aliases) {
    var colon_name = ":" + name + ":"
    var list_names = [name].concat(aliases).join(" ")
    var emoji = $("<i>", { alt: colon_name, title: colon_name, class: "emoji " + name })
    var emoji_name = $("<div>", { class: "emoji-name" }).html(name)
    var emoji_wrapper = $("<div>", { class: "emoji-wrapper" }).append(emoji, emoji_name)
    var alias_list = $("<span>", { class: "aliases" }).html(aliases.join(", "))
    var emoji_container = $("<div>", { class: "emoji-container", "data-names": list_names }).append(emoji_wrapper, alias_list)
    $(".emoji-loader").append(emoji_container)
  }

  var emoji_data, emojiNames = [], emojiAliases = []
  setTimeout(function() {
    if ($(".emoji-field").length > 0) {
      $("body").append($("<div>", { class: "emoji-loader small field-autofiller hidden" }))
    }
    $.getJSON("/emoji.json", function(data) {
      emoji_data = data
      for (var emojiName in emoji_data) {
        emojiNames.push(emojiName)
        emojiAliases = emojiAliases.concat(emoji_data[emojiName])
        addEmojiToLoader(emojiName, emoji_data[emojiName])
        if ($(".emoji-loader").hasClass("large")) { $(".emoji").addClass("large") }
        // if ($(".emoji-loader").hasClass("small")) { $(".emoji").addClass("small") }
      }
    })
  }, 10)

  filterEmojiFromText = function(search_text) {
    search_text = search_text.toLowerCase().replace(/[ \_\-\:]/, "")
    if (search_text.length == 0) {
      $(".emoji-container").removeClass("hidden")
    }

    $(".emoji-container").each(function() {
      var names = $(this).attr("data-names").split(" ")

      var hasMatched = false
      for (var name_idx in names) {
        if (hasMatched) { break }

        var name = names[name_idx], emojiText = name, string_valid = true
        emojiText = emojiText.replace(/[ \_\-\:]/, "")

        // NOTE: Word-based matching
        if (emojiText.indexOf(search_text) < 0) { string_valid = false }

        // NOTE: Character-based, order-dependent fuzzy matching
        // for (var idx in search_text.split("")) {
        //   if (hasMatched) { break }
        //
        //   var char = search_text[idx], char_index = emojiText.indexOf(char)
        //   if (char_index < 0) {
        //     string_valid = false
        //   } else {
        //     emojiText = emojiText.substr(char_index + 1)
        //   }
        // }

        if (string_valid) { hasMatched = true }
      }
      if (hasMatched) {
        $(this).removeClass("hidden")
      } else {
        $(this).addClass("hidden")
      }
    })
  }

  $(".emoji-quick-search").on("keyup", function() {
    var search_text = $(this).val()

    filterEmojiFromText(search_text)
  })

  caretPositionInField = function(text_field) {
    var caretPos = 0
    if (document.selection) {
      text_field.focus()
      var selection = document.selection.createRange()
      selection.moveStart('character', -text_field.value.length)
      caretPos = selection.text.length
    } else if (text_field.selectionStart || text_field.selectionStart == '0') {
      caretPos = text_field.selectionStart
    }
    return caretPos
  }

  wordFromPosition = function(text, caretPos) {
    var index = text.indexOf(caretPos)
    var preText = text.substring(0, caretPos)
    if (preText.indexOf(" ") > 0) {
      var words = preText.split(" ")
      return words[words.length - 1]
    } else {
      return preText
    }
  }

  currentWordForField = function(field) {
    var pos = caretPositionInField(field)
    return wordFromPosition(field.value, pos)
  }

  alignAutoFillerToFocusedField = function() {
    var focusedField = $(document.activeElement)
    if (!focusedField.hasClass("emoji-field")) { return }
    var fieldPos = focusedField.position()
    var popup = $(".field-autofiller")
    var popupHeight = popup.height()
    popup.css({ top: fieldPos.top - popupHeight, left: fieldPos.left, width: focusedField.outerWidth() })
  }

  $(window).scroll(function() {
    if (!$(".field-autofiller").hasClass("hidden")) {
      alignAutoFillerToFocusedField()
    }
  })

  $(".emoji-container").click(function() {
    // replace current word with emoji syntax
    // Hide popup
    // move cursor to end of emoji?
  })

  $(".emoji-field").on("keyup", function() {
    // TODO: Interrupt all non character events while popup is shown (Enter, Esc, Tab, arrow keys)
    //  Navigate currently shown emojis with those keys instead
    var currentWord = currentWordForField(this)
    if (currentWord[0] == ":" && currentWord[currentWord.length - 1] != ":") {
      filterEmojiFromText(currentWord)
      $(".field-autofiller").removeClass("hidden")
    } else {
      $(".field-autofiller").addClass("hidden")
    }
    alignAutoFillerToFocusedField()
  }).on("blur", function() {
    $(".field-autofiller").addClass("hidden")
  })

})
