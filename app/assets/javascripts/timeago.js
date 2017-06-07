var timeago_ms = {};
timeago_ms.second = 1000;
timeago_ms.minute = 60 * timeago_ms.second;
timeago_ms.hour = 60 * timeago_ms.minute;
timeago_ms.day = 24 * timeago_ms.hour;
timeago_ms.week = 7 * timeago_ms.day;
timeago_ms.month = 30 * timeago_ms.day;
timeago_ms.year = 12 * timeago_ms.month;

inWords = function(from_epoch, options) {
  options = options || {}
  var start_time = options.start_time || ((new Date()).getTime() / 1000)
  var word_count = options.word_count || 2
  var distanceMs = (start_time - Math.abs(from_epoch)) * 1000;
  var words = []

  var tempMs = distanceMs;
  $(Object.keys(timeago_ms).reverse()).each(function() {
    var msForTime = timeago_ms[this], time = this.toString();
    if (tempMs > msForTime) {
      var word_count = Math.floor(tempMs / msForTime), pluralize = word_count > 1 ? "s" : ""
      words.push(" " + word_count + " " + time + pluralize);
      tempMs = tempMs % msForTime;
    }
  })

  var suffix = distanceMs < 0 ? "from now" : "ago"
  return $.trim([words.slice(0, word_count), suffix].join(" "));
}

timeago = function(time_ele) {
  $time_ele = $(time_ele);
  var words = inWords($time_ele.attr('datetime'));
  $time_ele.html(words);
};

refreshTimeago = function() {
  $('time.timeago').each(function() {
    timeago(this);
  })
}

$(document).ready(function() {
  refreshTimeago();
  setInterval(function() {
    refreshTimeago();
  }, 500);
})
