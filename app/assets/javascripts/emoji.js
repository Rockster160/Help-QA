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

  function setSelectionRange(input, selectionStart, selectionEnd) {
    if (input.setSelectionRange) {
      input.focus();
      input.setSelectionRange(selectionStart, selectionEnd);
    } else if (input.createTextRange) {
      var range = input.createTextRange();
      range.collapse(true);
      range.moveEnd('character', selectionEnd);
      range.moveStart('character', selectionStart);
      range.select();
    }
  }

  getCoordsOfCaretInField = function(field) {
    var selPos = caretPositionInField(field)
    var lines = $(field).val().split("\n")
    var currentLine = 0, currentCol = selPos
    lines.find(function(line) {
      if (line.length >= currentCol) {
        return true
      } else {
        currentCol -= line.length + 1
        currentLine += 1
      }
    })
    return [currentCol, currentLine]
  }

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
    var startIdx = caretPos - 1, endIdx = caretPos - 1
    while (text[endIdx] != undefined && text[endIdx] != " " && text[endIdx] != "\n") { endIdx += 1; }
    while (text[startIdx] != undefined && text[startIdx] != " " && text[startIdx] != "\n") { startIdx -= 1 }
    return text.substring(startIdx + 1, endIdx)
  }

  currentWordForField = function(field) {
    var pos = caretPositionInField(field)
    return wordFromPosition(field.value, pos)
  }

  alignAutoFillerToFocusedField = function() {
    var focusedField = $(document.activeElement)
    if (!focusedField.hasClass("emoji-field")) { return }
    var fieldPos = focusedField.offset()
    var popup = $(".field-autofiller")
    var popupHeight = popup.height()
    popup.css({ top: fieldPos.top - popupHeight, left: fieldPos.left, width: focusedField.outerWidth() })
  }

  emojiPopupVisible = function() {
    return !$(".field-autofiller").hasClass("hidden")
  }

  getVisibleEmoji = function() {
    if (!emojiPopupVisible()) { return $("") }
    var parentBB = $(".field-autofiller").get(0).getBoundingClientRect()
    return $(".emoji-container:not(.hidden)").filter(function() {
      var emojiBB = this.getBoundingClientRect()
      return emojiBB.top + emojiBB.height < parentBB.top + parentBB.height
    })
  }

  selectEmoji = function(emoji) {
    $(".emoji-container").removeClass("selected")
    $(emoji).addClass("selected")
  }

  getEmojiAtPoint = function(emojis, point) {
    return emojis.toArray().find(function(emoji) {
      var thisBB = emoji.getBoundingClientRect()
      return thisBB.left < point.left && thisBB.top < point.top &&
        thisBB.right > point.left && thisBB.bottom > point.top
    })
  }

  getEmojiAroundPoint = function(emojis, point) {
    var withRadius = 5
    var emoji
    var nextPoint = point

    emoji = getEmojiAtPoint(emojis, nextPoint)
    if ($(emoji).length > 0) { return emoji }

    nextPoint = point
    nextPoint.left = point.left - withRadius
    emoji = getEmojiAtPoint(emojis, nextPoint)
    if ($(emoji).length > 0) { return emoji }

    nextPoint = point
    nextPoint.right = point.right - withRadius
    emoji = getEmojiAtPoint(emojis, nextPoint)
    if ($(emoji).length > 0) { return emoji }
  }

  selectNextEmoji = function() {
    var visibleEmoji = getVisibleEmoji()
    var currentEmoji = $(".emoji-container.selected")
    var selectedIdx = visibleEmoji.index(currentEmoji)
    var newEmoji = visibleEmoji[selectedIdx + 1] || getVisibleEmoji().first()
    selectEmoji(newEmoji)
  }

  selectPrevEmoji = function() {
    var visibleEmoji = getVisibleEmoji()
    var currentEmoji = $(".emoji-container.selected")
    var selectedIdx = visibleEmoji.index(currentEmoji)
    var newEmoji = visibleEmoji[selectedIdx - 1] || getVisibleEmoji().last()
    selectEmoji(newEmoji)
  }

  selectDownRowEmoji = function() {
    var visibleEmoji = getVisibleEmoji()
    var currentEmoji = $(".emoji-container.selected")
    var emojiBB = currentEmoji.get(0).getBoundingClientRect()
    var centerPoint = { left: emojiBB.left + (emojiBB.width / 2), top: emojiBB.top + (emojiBB.height / 2) }
    var newEmoji
    // Below - Default, check next row down
    var belowPoint = { left: centerPoint.left, top: centerPoint.top + emojiBB.height }
    newEmoji = getEmojiAroundPoint(visibleEmoji, belowPoint)
    if (newEmoji) { return selectEmoji(newEmoji) }
    // Top - Already at the bottom, move to the top
    var topPoint = { left: centerPoint.left, top: centerPoint.top - (emojiBB.height * 2) }
    newEmoji = getEmojiAroundPoint(visibleEmoji, topPoint)
    if (newEmoji) { return selectEmoji(newEmoji) }
    // Above - Covers case where there are only 2 rows, get the "next" top
    var abovePoint = { left: centerPoint.left, top: centerPoint.top - emojiBB.height }
    newEmoji = getEmojiAroundPoint(visibleEmoji, abovePoint)
    if (newEmoji) { return selectEmoji(newEmoji) }
  }

  selectUpRowEmoji = function() {
    var visibleEmoji = getVisibleEmoji()
    var currentEmoji = $(".emoji-container.selected")
    var emojiBB = currentEmoji.get(0).getBoundingClientRect()
    var centerPoint = { left: emojiBB.left + (emojiBB.width / 2), top: emojiBB.top + (emojiBB.height / 2) }
    var newEmoji
    // Above - Default, check next row up
    var abovePoint = { left: centerPoint.left, top: centerPoint.top - emojiBB.height }
    newEmoji = getEmojiAroundPoint(visibleEmoji, abovePoint)
    if (newEmoji) { return selectEmoji(newEmoji) }
    // Bottom - Already at the top, move to the bottom
    var topPoint = { left: centerPoint.left, top: centerPoint.top + (emojiBB.height * 2) }
    newEmoji = getEmojiAroundPoint(visibleEmoji, topPoint)
    if (newEmoji) { return selectEmoji(newEmoji) }
    // Below - Covers case where there are only 2 rows, get the "next" bottom
    var belowPoint = { left: centerPoint.left, top: centerPoint.top + emojiBB.height }
    newEmoji = getEmojiAroundPoint(visibleEmoji, belowPoint)
    if (newEmoji) { return selectEmoji(newEmoji) }
  }

  confirmEmoji = function() {
    var currentEmoji = $(".emoji-container.selected")
    var emoji_name = currentEmoji.find(".emoji-name").text()
    var field = $(document.activeElement).focus()
    var text = field.val()
    var pos = currentCaretPos, startIdx = pos - 1, endIdx = pos
    while (text[startIdx] != undefined && text[startIdx] != " " && text[startIdx] != "\n") { startIdx -= 1; }
    while (text[endIdx] != undefined && text[endIdx] != " " && text[endIdx] != "\n") { endIdx += 1; }

    field.val(
      field.val().substring(0, startIdx + 1) +
      ":" + emoji_name + ": " +
      field.val().substring(endIdx + 1, field.val().length)
    )

    $(".field-autofiller").addClass("hidden")
    setSelectionRange(field, endIdx + 1, endIdx + 1)
  }

  pressedEmojiNavigationKey = function(key) {
    switch(key.which) {
      case keyEvent("ENTER"):
      case keyEvent("LEFT"):
      case keyEvent("UP"):
      case keyEvent("TAB"):
      case keyEvent("RIGHT"):
      case keyEvent("DOWN"):
        return true
      default:
        return false
    }
  }

  $(window).scroll(function() {
    if (emojiPopupVisible()) {
      alignAutoFillerToFocusedField()
    }
  })

  $(document).on("mouseenter", ".emoji-container", function() {
    selectEmoji(this)
  }).on("mousedown", ".emoji-container", function(evt) {
    evt.preventDefault()
    return false
  }).on("mouseup", ".emoji-container", function() {
    confirmEmoji()
  })

  var currentCaretPos = 0
  $(".emoji-field").on("keydown", function(evt) {
    if (!$(".field-autofiller").hasClass("hidden")) {
      switch(evt.which) {
        case keyEvent("ENTER"):
          confirmEmoji()
          evt.preventDefault()
          return false
        case keyEvent("LEFT"):
          selectPrevEmoji()
          evt.preventDefault()
          return false
        case keyEvent("UP"):
          selectUpRowEmoji()
          evt.preventDefault()
          return false
        case keyEvent("TAB"):
        case keyEvent("RIGHT"):
          selectNextEmoji()
          evt.preventDefault()
          return false
        case keyEvent("DOWN"):
          selectDownRowEmoji()
          evt.preventDefault()
          return false
      }
    }
  }).on("keyup focus mouseup", function(evt) {
    if (pressedEmojiNavigationKey(evt)) { return }
    currentCaretPos = caretPositionInField(this)
    var currentWord = currentWordForField(this)
    console.log("Word:", currentWord);
    console.log("Char:", currentWord[0]);
    console.log("Last:", currentWord[currentWord.length - 1]);
    if (currentWord[0] == ":" && currentWord[currentWord.length - 1] != ":") {
      filterEmojiFromText(currentWord)
      $(".field-autofiller").removeClass("hidden")
      alignAutoFillerToFocusedField()
    } else {
      $(".field-autofiller").addClass("hidden")
    }
    selectEmoji(getVisibleEmoji().first())
  }).on("blur", function() {
    $(".field-autofiller").addClass("hidden")
  })

})
