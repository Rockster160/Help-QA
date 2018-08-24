function repositionPopups() {
  $(".markdown-tools:not(.hidden)").each(function() {
    var toolWrapper = $(this)
    var textarea = toolWrapper.siblings("textarea")
    var fieldPos = textarea.offset()
    var popupHeight = toolWrapper.height()
    toolWrapper.css({ top: fieldPos.top - popupHeight - 7, left: fieldPos.left, width: textarea.outerWidth() })
  })
}

function insertAtCursor(field, insertBefore, insertAfter) {
  if (document.selection) {
    field.focus()
    document.selection.createRange().text = insertBefore + document.selection.createRange().text + insertAfter
  } else if (field.selectionStart || field.selectionStart == '0') {
    var startPos = field.selectionStart
    var endPos = field.selectionEnd
    field.value = field.value.substring(0, startPos) +
      insertBefore +
      field.value.substring(startPos, endPos) +
      insertAfter +
      field.value.substring(endPos, field.value.length)
  }
}

function insertAroundCursor(field, insertAround) {
  insertAtCursor(field, insertAround, insertAround)
}

$(document).on("focus", "textarea", function() {
}).on("click", ".tool-cell", function(evt) {
  var field = $(this).parents(".markdown-tools").siblings("textarea").get(0)
  console.log(field);
  evt.preventDefault()
  insertAroundCursor(field, "*")
  return false
}).on("blur", "textarea", function(evt) {
  if ($(evt.target).closest(".markdown-tools").length > 0) {
    evt.preventDefault()
    return false
  } else {
  }
}).on("click", ".tools-toggle-button", function() {
  $(this).siblings(".markdown-tools").toggleClass("hidden")
  repositionPopups()
})
// $(".markdown-tools").addClass("hidden")

$(window).on("scroll resize", repositionPopups)
