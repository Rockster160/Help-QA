$(".ctr-static_pages.act-donate").ready(function() {
  $("input[type=radio][name=currency]").change(function() {
    var selected_currency = $("input[type=radio][name=currency]:checked").val()
    $("[data-currency-show]").addClass("hidden")
    $("[data-currency-show=" + selected_currency + "]").removeClass("hidden")
  })
})
