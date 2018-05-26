$(document).ready(function() {

  $("[data-masterCheckbox]").change(function() {
    $("[data-followsMaster='#" + this.id + "']").prop("checked", this.checked)
  })

  $(document)
    .on("click tap", ".whispercontrol", toggleWhisperDisplay)
    .on("click tap", ".removed-shout.clickable", displayShout)

})

function toggleWhisperDisplay() {
  $(this).next(".whispercontent").toggleClass("hidden")
}

function displayShout() {
  $(this).next(".shout-container.removed").toggleClass("hidden")
}
