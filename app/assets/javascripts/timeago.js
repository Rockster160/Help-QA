timeago = function(time) {
  $time = $(time);
  var words = inWords($time.attr('datetime'));
  // $time.attr('title');
  $time.html(words);
};

var settings = {
  allowPast: true,
  allowFuture: false,
  strings: {
    prefixAgo: null,
    prefixFromNow: null,
    suffixAgo: "ago",
    suffixFromNow: "from now",
    inPast: 'any moment now',
    second: "moments",
    seconds: "less than a minute",
    minute: "about a minute",
    minutes: "%d minutes",
    hour: "about an hour",
    hours: "about %d hours",
    day: "a day",
    days: "%d days",
    month: "about a month",
    months: "%d months",
    year: "about a year",
    years: "%d years",
    wordSeparator: " ",
    numbers: []
  }
}

inWords = function(from_epoch) {
  var distanceSeconds = ((new Date()).getTime() / 1000) - Math.abs(from_epoch)
  var $l = this.settings.strings;
  var prefix = $l.prefixAgo;
  var suffix = $l.suffixAgo;
  if (distanceSeconds < 0) {
    prefix = $l.prefixFromNow;
    suffix = $l.suffixFromNow;
  }

  var seconds = distanceSeconds;
  var minutes = seconds / 60;
  var hours = minutes / 60;
  var days = hours / 24;
  var years = days / 365;
  function substitute(string, number) {
    var value = ($l.numbers && $l.numbers[number]) || number;
    return string.replace(/%d/i, value);
  }

  var words = seconds < 30 && substitute($l.second, Math.round(seconds)) ||
  seconds < 45 && substitute($l.seconds, Math.round(seconds)) ||
  seconds < 90 && substitute($l.minute, 1) ||
  minutes < 45 && substitute($l.minutes, Math.round(minutes)) ||
  minutes < 90 && substitute($l.hour, 1) ||
  hours < 24 && substitute($l.hours, Math.round(hours)) ||
  hours < 42 && substitute($l.day, 1) ||
  days < 30 && substitute($l.days, Math.round(days)) ||
  days < 45 && substitute($l.month, 1) ||
  days < 365 && substitute($l.months, Math.round(days / 30)) ||
  years < 1.5 && substitute($l.year, 1) ||
  substitute($l.years, Math.round(years));

  var separator = $l.wordSeparator || "";
  if ($l.wordSeparator === undefined) { separator = " "; }
  return $.trim([prefix, words, suffix].join(separator));
}

refreshTimeago = function() {
  $('time.timeago').each(function() {
    timeago(this);
  })
}

$(document).ready(function() {
  refreshTimeago();
  setInterval(function() {
    refreshTimeago();
  }, 10000);
})
