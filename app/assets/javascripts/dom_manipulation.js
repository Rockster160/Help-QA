$(document).ready(function() {

  $("[data-masterCheckbox]").change(function() {
    $("[data-followsMaster='#" + this.id + "']").prop("checked", this.checked)
  })

})
