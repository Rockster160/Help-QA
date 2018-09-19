$(document).ready(function() {

  filterOptionsFromText = function(loader, search_text) {
    search_text = search_text.toLowerCase().replace(/[ \_\-\:\@]/, "")

    loader.find(".searchable-container").each(function() {
      var names = $(this).attr("data-searchable-by").toLowerCase().split(" ")

      var hasMatched = search_text.length == 0
      for (var name_idx in names) {
        if (hasMatched) { break }

        var name = names[name_idx], searchableText = name, string_valid = true
        searchableText = searchableText.replace(/[ \_\-\:\@]/, "")

        // Full word-based matching
        if (searchableText.indexOf(search_text) < 0) { string_valid = false }

        if (string_valid) { hasMatched = true }
      }
      if (hasMatched) {
        $(this).removeClass("hidden")
      } else {
        $(this).addClass("hidden")
      }
    })
  }

  setSelectionRange = function(input, selectionStart, selectionEnd) {
    input = $(input).get(0)
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
    var fieldPos = focusedField.offset()
    $(".field-autofiller:not(.hidden)").each(function() {
      var popup = $(this)
      var containers = popup.find(".searchable-container:not(.hidden)")
      var maxHeight = ((containers.outerHeight() + parseInt(containers.css("margin"))) * 3) + 5
      popup.css({ "max-height": maxHeight })
      var popupHeight = popup.height()
      popup.css({ top: fieldPos.top - popupHeight, left: fieldPos.left, width: focusedField.outerWidth() })
    })
  }

  autofillerPopupVisible = function() {
    return $(".field-autofiller:not(.hidden)").length > 0
  }

  getVisibleOptions = function() {
    if (!autofillerPopupVisible()) { return $("") }
    var parent = $(".field-autofiller:not(.hidden)")
    var parentBB = parent.get(0).getBoundingClientRect()
    return parent.find(".searchable-container:not(.hidden)").filter(function() {
      var optionBB = this.getBoundingClientRect()
      return optionBB.top + optionBB.height < parentBB.top + parentBB.height
    })
  }

  selectOption = function(option) {
    $(".searchable-container").removeClass("selected")
    $(option).addClass("selected")
  }

  getOptionAtPoint = function(options, point) {
    return options.toArray().find(function(option) {
      var optionBB = option.getBoundingClientRect()
      return optionBB.left < point.left && optionBB.top < point.top &&
        optionBB.right > point.left && optionBB.bottom > point.top
    })
  }

  getOptionAroundPoint = function(options, point) {
    var withRadius = 5
    var option
    var nextPoint = point

    option = getOptionAtPoint(options, nextPoint)
    if ($(option).length > 0) { return option }

    nextPoint = point
    nextPoint.left = point.left - withRadius
    option = getOptionAtPoint(options, nextPoint)
    if ($(option).length > 0) { return option }

    nextPoint = point
    nextPoint.right = point.right - withRadius
    option = getOptionAtPoint(options, nextPoint)
    if ($(option).length > 0) { return option }
  }

  selectNextOption = function() {
    var visibleOption = getVisibleOptions()
    var currentOption = $(".searchable-container.selected")
    if (currentOption.length == 0) { return }
    var selectedIdx = visibleOption.index(currentOption)
    var newOption = visibleOption[selectedIdx + 1] || getVisibleOptions().first()
    selectOption(newOption)
  }

  selectPrevOption = function() {
    var visibleOption = getVisibleOptions()
    var currentOption = $(".searchable-container.selected")
    if (currentOption.length == 0) { return }
    var selectedIdx = visibleOption.index(currentOption)
    var newOption = visibleOption[selectedIdx - 1] || getVisibleOptions().last()
    selectOption(newOption)
  }

  selectDownRowOption = function() {
    var visibleOption = getVisibleOptions()
    var currentOption = $(".searchable-container.selected")
    if (currentOption.length == 0) { return }
    var optionBB = currentOption.get(0).getBoundingClientRect()
    var centerPoint = { left: optionBB.left + (optionBB.width / 2), top: optionBB.top + (optionBB.height / 2) }
    var newOption
    // Below - Default, check next row down
    var belowPoint = { left: centerPoint.left, top: centerPoint.top + optionBB.height }
    newOption = getOptionAroundPoint(visibleOption, belowPoint)
    if (newOption) { return selectOption(newOption) }
    // Top - Already at the bottom, move to the top
    var topPoint = { left: centerPoint.left, top: centerPoint.top - (optionBB.height * 2) }
    newOption = getOptionAroundPoint(visibleOption, topPoint)
    if (newOption) { return selectOption(newOption) }
    // Above - Covers case where there are only 2 rows, get the "next" top
    var abovePoint = { left: centerPoint.left, top: centerPoint.top - optionBB.height }
    newOption = getOptionAroundPoint(visibleOption, abovePoint)
    if (newOption) { return selectOption(newOption) }
  }

  selectUpRowOption = function() {
    var visibleOption = getVisibleOptions()
    var currentOption = $(".searchable-container.selected")
    if (currentOption.length == 0) { return }
    var optionBB = currentOption.get(0).getBoundingClientRect()
    var centerPoint = { left: optionBB.left + (optionBB.width / 2), top: optionBB.top + (optionBB.height / 2) }
    var newOption
    // Above - Default, check next row up
    var abovePoint = { left: centerPoint.left, top: centerPoint.top - optionBB.height }
    newOption = getOptionAroundPoint(visibleOption, abovePoint)
    if (newOption) { return selectOption(newOption) }
    // Bottom - Already at the top, move to the bottom
    var topPoint = { left: centerPoint.left, top: centerPoint.top + (optionBB.height * 2) }
    newOption = getOptionAroundPoint(visibleOption, topPoint)
    if (newOption) { return selectOption(newOption) }
    // Below - Covers case where there are only 2 rows, get the "next" bottom
    var belowPoint = { left: centerPoint.left, top: centerPoint.top + optionBB.height }
    newOption = getOptionAroundPoint(visibleOption, belowPoint)
    if (newOption) { return selectOption(newOption) }
  }

  confirmOption = function() {
    var currentOption = $(".searchable-container.selected")
    if (currentOption.length == 0) { return }
    if (currentOption.length == 0) { return }
    var option_name = currentOption.find(".option-name").text()
    var field = $(document.activeElement).focus()
    var text = field.val()
    var pos = currentCaretPos, startIdx = pos - 1, endIdx = pos
    while (text[startIdx] != undefined && text[startIdx] != " " && text[startIdx] != "\n") { startIdx -= 1; }
    while (text[endIdx] != undefined && text[endIdx] != " " && text[endIdx] != "\n") { endIdx += 1; }

    var prefill_value = option_name
    if (currentOption.attr("data-type") == "emoji") { prefill_value = option_name + " " }
    if (currentOption.attr("data-type") == "username") { prefill_value = option_name + " " }

    field.val(
      field.val().substring(0, startIdx + 1) +
      prefill_value +
      field.val().substring(endIdx + 1, field.val().length)
    )
    var newIdx = startIdx + prefill_value.length

    $(".field-autofiller").addClass("hidden")
    setSelectionRange(field, newIdx, newIdx)
  }

  pressedSearchableChar = function(key) {
    var charCode = key.which
    if (charCode >= keyEvent("A") && charCode <= keyEvent("Z")) {
      return true
    } else if (charCode >= keyEvent("0") && charCode <= keyEvent("9")) {
      return true
    } else if (charCode == keyEvent("+") || charCode == keyEvent("-") || charCode == keyEvent("_")) {
      return true
    } else {
      return false
    }
  }

  pressedOptionNavigationKey = function(key) {
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
    if (autofillerPopupVisible()) {
      alignAutoFillerToFocusedField()
    }
  })

  $(document).on("mouseenter touchstart", ".searchable-container", function() {
    selectOption(this)
  }).on("mousedown", ".searchable-container", function(evt) {
    evt.preventDefault()
    return false
  }).on("mouseup touchend tap", ".searchable-container", function() {
    confirmOption()
  })

  $(".emoji-quick-search").on("keyup", function() {
    var search_text = $(this).val()

    filterOptionsFromText($(".emoji-loader"), search_text)
  })

  var currentCaretPos = 0
  $(".autofillable-field").on("keydown", function(evt) {
    if (autofillerPopupVisible()) {
      switch(evt.which) {
        case keyEvent("ENTER"):
          confirmOption()
          evt.preventDefault()
          return false
        case keyEvent("LEFT"):
          selectPrevOption()
          evt.preventDefault()
          return false
        case keyEvent("UP"):
          selectUpRowOption()
          evt.preventDefault()
          return false
        case keyEvent("TAB"):
        case keyEvent("RIGHT"):
          selectNextOption()
          evt.preventDefault()
          return false
        case keyEvent("DOWN"):
          selectDownRowOption()
          evt.preventDefault()
          return false
      }
    }
    // Only open field when the starting char is entered (:@) or values are entered as part of the current word
    // When hitting escape, close the current popup - since it's closed, arrow keys should no longer be disabled.
  }).on("keyup focus mouseup", function(evt) {
    if (pressedOptionNavigationKey(evt)) { return }
    if (autofillerPopupVisible()) {
      if (keyEvent("ESC") == evt.which) {
        evt.preventDefault()
        $(".field-autofiller").addClass("hidden")
        return false
      }
    }
    currentCaretPos = caretPositionInField(this)
    var currentWord = currentWordForField(this)
    console.log(currentWord);
    if ((currentWord[0] == ":" || currentWord[0] == "@") && (currentWord.length == 1 || currentWord[currentWord.length - 1] != ":")) {
      var loader
      if (currentWord[0] == ":") { loader = $(".emoji-loader") }
      if (currentWord[0] == "@") { loader = $(".username-loader") }

      filterOptionsFromText(loader, currentWord)

      // Show loader if there are any options present
      if (loader.find(".searchable-container:not(.hidden)").length > 0) { loader.removeClass("hidden") }
      alignAutoFillerToFocusedField()
    } else {
      $(".field-autofiller").addClass("hidden")
    }
    selectOption(getVisibleOptions().first())
  }).on("blur", function() {
    $(".field-autofiller").addClass("hidden")
  })

})
