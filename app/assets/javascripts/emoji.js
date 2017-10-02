// $(document).ready(function() {
//
//   var emoji_data, emojiNames = [], emojiAliases = []
//   setTimeout(function() {
//     $.getJSON("/emoji.json", function(data) {
//       emoji_data = data
//       for (var emojiName in emoji_data) {
//         emojiNames.push(emojiName)
//         emojiAliases = emojiAliases.concat(emoji_data[emojiName])
//       }
//       emojify()
//     })
//   }, 1)
//
//   emoji = function(icon) {
//     icon = icon.replace(":", "").toLowerCase()
//
//     if (emojiNames.indexOf(icon) < 0) {
//       // Doesn't exist, return the original string
//       return ":" + icon + ":"
//     }
//
//     var new_emoji = $("#pre-load .emoji").clone()
//     new_emoji.attr("alt", ":" + icon + ":")
//     new_emoji.attr("title", ":" + icon + ":")
//     new_emoji.removeClass("blank").addClass(icon)
//
//     return $("<span>").html(new_emoji).get(0).innerHTML
//   }
//
//   emojify = function(selector) {
//     selector = selector || "body"
//     var not_between_carrots_regex = /[^<>]+(?![^<]*>)/g
//     var emoji_regex = /([^a-zA-Z0-9\\]?)\:([^ \n]+?)\:/g
//
//     $(selector).each(function() {
//       this.innerHTML = this.innerHTML.replace(not_between_carrots_regex, function(match) {
//         return match.replace(emoji_regex, function(emoji_match, group1, group2) {
//           if (group1) {
//             return group1 + emoji(group2)
//           } else {
//             return emoji(group2)
//           }
//         })
//       })
//     })
//   }
//
// })
