// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

// http://keycode.info
keyEvent = function(char) {
  var upChar = char.toUpperCase()
  switch(upChar) {
    case "ENTER":
      return 13;
    case "TAB":
      return 9;
    case "SPACE":
      return 32;
    case "ESC":
      return 27;
    case "LEFT":
      return 37;
    case "UP":
      return 38;
    case "DOWN":
      return 40;
    case "RIGHT":
      return 39;
    default:
      return char.charCodeAt(0)
  }
}
