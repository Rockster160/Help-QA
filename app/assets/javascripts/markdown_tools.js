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
    setSelectionRange(field, startPos + insertBefore.length, endPos + insertBefore.length)
  }
  $(field).focus()
}

$(document).on("click tap touchend mouseup", ".tool-cell", function(evt) {
  evt.preventDefault()
  var field = $(this).parents(".markdown-tools").siblings("textarea").get(0)
  var beforeText = $(this).attr("data-markdown-open").replace("\\n", "\n")
  var afterText = $(this).attr("data-markdown-close").replace("\\n", "\n")
  insertAtCursor(field, beforeText, afterText)
  return false
}).on("click tap touchend mouseup", ".open-tools", function() {
  var tools = $(this).siblings(".markdown-tools")
  var field = $(this).siblings("textarea")
  tools.removeClass("hidden")
  field.css("padding-top", tools.outerHeight())
}).on("click tap touchend mouseup", ".close-tools", function() {
  var tools = $(this).parents(".markdown-tools")
  var field = tools.siblings("textarea")
  field.css("padding-top", "0")
  tools.addClass("hidden")
})
