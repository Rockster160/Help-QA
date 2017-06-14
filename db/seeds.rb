def random_time_between_now_and(this_time, most_recent_allowed=1.hour.ago)
  times = [most_recent_allowed, this_time].sort
  rand(times[0]..times[1])
end

def random_body_with_whitespace(paragraph_count)
  raw_body = Faker::Lorem.paragraph(2, true, paragraph_count)
  body_pieces = raw_body.split(".")
  body = ""
  body_pieces.each do |body_piece|
    body += body_piece + "." + ("\n"*rand(3))
  end
  body
end

def print_next_number(num)
  prev_num_length = (num.to_i + 1).to_s.length
  sleep 0.001
  print "\b\b"
  print "\b"*prev_num_length
  print " "*prev_num_length
  print "\b"*prev_num_length
  print "#{num}  "
end

start_date = 5.years.ago
shout_conversations = 1000
users = 1000
posts = 300
replies = 2000

# puts "\nGenerating People...\n"
# Rando.people(users).each_with_index do |person, person_idx|
#   print_next_number(users - person_idx)
#   u = User.new
#   u.skip_confirmation!
#   email_with_idx = person.email.split("@").join("#{User.count}@")
#
#   u.email = email_with_idx
#   u.password = "password"
#
#   created = random_time_between_now_and(start_date)
#   u.created_at = created
#   u.remember_created_at = created
#   u.last_seen_at = rand(10) == 0 ? random_time_between_now_and([1.week.ago, created].max) : random_time_between_now_and(created)
#
#   u.username = "#{User.count}#{person.login.username}"
#   u.avatar_url = rand(3) == 0 ? person.picture.thumbnail : nil
#
#   u.save
#
#   location = u.build_location
#   location.ip = (0..255).to_a.sample(4).join(".")
#   location.city = person.location.city
#   location.zip_code = person.location.postcode
#
#   location.save
# end

puts "\nGenerating Shout Conversations...\n"
shout_conversations.times do |conv_idx|
  print_next_number(shout_conversations - conv_idx)

  user1, user2 = User.all.sample(2)

  message_count = (rand(50) + rand(50) + rand(100)) / 3
  last_message_at = random_time_between_now_and([user1.created_at, user2.created_at].max, 1.second.from_now)
  print "\b\b.#{message_count}  "
  message_count.times do |msg_idx|
    print_next_number(message_count - msg_idx)
    if DateTime.current.to_i - last_message_at.to_i > 1000
      to, from = [user1, user2].shuffle
      to.shouts_from.create(sent_to: from, body: random_body_with_whitespace(2), created_at: last_message_at)
      last_message_at = random_time_between_now_and(last_message_at + 5.minutes, 1.second.from_now)
    end
  end
  print "\b\b"
end

# puts "\nGenerating Posts...\n"
# posts.times do |post_idx|
#   print_next_number(posts - post_idx)
#
#   author = User.all.sample
#   post = author.posts.new
#   post.created_at = random_time_between_now_and(author.created_at)
#   post.body = random_body_with_whitespace(10)
#   post.posted_anonymously = rand(4) == 0
#
#   post.save
# end
#
# puts "\nGenerating Post Replies...\n"
# replies.times do |reply_idx|
#   print_next_number(replies - reply_idx)
#
#   author = User.all.sample
#   post = Post.all.sample
#   reply = post.replies.new
#   reply.author = author
#   reply.created_at = random_time_between_now_and([post.created_at, author.created_at].max)
#   reply.body = random_body_with_whitespace(6)
#   reply.posted_anonymously = rand(10) == 0
#
#   reply.save
# end
#
# puts "\nGenerating Post Views...\n"
# all_posts = Post.all
# all_posts_count = all_posts.count
#
# all_posts.each_with_index do |post, post_idx|
#   puts "Post: #{post_idx + 1} / #{all_posts_count}\nViews:"
#
#   view_count = case rand(10)
#   when 0..3 then rand(30)
#   when 4..5 then rand(70)
#   when 6..9 then rand(100)
#   when 10 then rand(1000)
#   end
#
#   view_count.times do |view_idx|
#     print_next_number(view_count - view_idx)
#     view = post.views.new
#     viewer = User.all.sample
#     view.viewed_by = viewer
#     view.created_at = random_time_between_now_and([post.created_at, viewer.created_at].max)
#
#     view.save
#   end
# end
