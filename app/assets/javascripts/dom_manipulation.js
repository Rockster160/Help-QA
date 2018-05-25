$(document).ready(function() {

  $("[data-masterCheckbox]").change(function() {
    $("[data-followsMaster='#" + this.id + "']").prop("checked", this.checked)
  })

  $(document).on("click tap", ".whispercontrol", toggleWhisperDisplay)

})

function toggleWhisperDisplay() {
  $(this).next(".whispercontent").toggleClass("hidden")
}
