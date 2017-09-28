User.create({
  email: "rocco11nicholls+helpbot@gmail.com",
  password: (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(20),
  created_at: 1.year.ago,
  remember_created_at: 1.year.ago,
  username: "HelpBot",
  confirmed_at: 1.year.ago,
  date_of_birth: Date.strptime("07/22/1993", "%m/%d/%Y"),
  avatar_url: ActionController::Base.helpers.asset_path("HelpBotjpg")
})

unless Rails.env.production?
  def random_time_between_now_and(this_time, most_recent_allowed=1.second.ago)
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

  def print_inline(msg)
    print "\r#{' '*100}\r#{msg}  "
  end

  def linearly_biased_random_number(min, max)
    ((rand - rand).abs * (1 + max - min) + min).floor
  end

  start_date = 5.years.ago
  shout_conversations = 100
  users_count = 100
  max_friend_count_per_user = 30
  posts = 100
  replies = 500

  u = User.create({
    email: "rocco11nicholls@gmail.com",
    password: "password",
    created_at: 6.months.ago,
    remember_created_at: 6.months.ago,
    username: "Rockster160",
    date_of_birth: Date.strptime("07/22/1993", "%m/%d/%Y")
  })
  u.confirm

  Rando.people(users_count).each_with_index do |person, person_idx|
    print_inline("Users: #{users_count - person_idx} / #{users_count}")
    u = User.new
    u.skip_confirmation!
    email_with_idx = person.email.split("@").join("#{User.count}@")

    u.email = email_with_idx
    u.password = "password"

    created = random_time_between_now_and(start_date)
    u.created_at = created
    u.remember_created_at = created
    u.last_seen_at = rand(10) == 0 ? random_time_between_now_and([1.week.ago, created].max) : random_time_between_now_and(created)

    u.username = "#{person.login.username.gsub(/\d/, '')}#{User.count}"
    u.date_of_birth = random_time_between_now_and(50.years.ago, 10.years.ago).to_date
    u.avatar_url = rand(3) == 0 ? person.picture.thumbnail : nil

    u.save

    if rand(3) == 0
      u.confirm
      verify_date = random_time_between_now_and(u.created_at)
      u.update(confirmed_at: verify_date, verified_at: verify_date)
    end

    location = u.build_location
    location.ip = (0..255).to_a.sample(4).join(".")
    location.city = person.location.city
    location.zip_code = person.location.postcode

    location.save
  end

  puts "\n"
  u_count = User.count
  User.find_each.with_index do |user, user_idx|
    print_inline("Friends: #{u_count - user_idx} / #{u_count}")

    friends_count = linearly_biased_random_number(0, max_friend_count_per_user)
    friends_count.times do |friend_idx|
      print_inline("User: #{u_count - user_idx} / #{u_count} - Friends: #{friends_count - friend_idx} / #{friends_count}")
      user.add_friend(User.all.sample)
    end
  end

  puts "\n"
  shout_conversations.times do |conv_idx|
    print_inline("Shouts: #{shout_conversations - conv_idx} / #{shout_conversations}")

    user1, user2 = User.all.sample(2)

    message_count = (rand(50) + rand(50) + rand(100)) / 3
    last_message_at = random_time_between_now_and([user1.created_at, user2.created_at].max, 1.second.from_now)
    message_count.times do |msg_idx|
      print_inline("Shouts: #{shout_conversations - conv_idx} / #{shout_conversations} - Messages: #{message_count - msg_idx} / #{message_count}")
      if DateTime.current.to_i - last_message_at.to_i > 1000
        to, from = [user1, user2].shuffle
        to.shouts_from.create(sent_to: from, body: random_body_with_whitespace(2), created_at: last_message_at)
        last_message_at = random_time_between_now_and(last_message_at + 5.minutes, 1.second.from_now)
      end
    end
  end

  puts "\n"
  posts.times do |post_idx|
    print_inline("Posts: #{posts - post_idx} / #{posts}")

    author = User.all.sample
    post = author.posts.new
    post.created_at = random_time_between_now_and(author.created_at)
    post.body = random_body_with_whitespace(10)
    post.posted_anonymously = rand(4) == 0

    post.save
  end

  puts "\n"
  replies.times do |reply_idx|
    print_inline("Replies: #{replies - reply_idx} / #{replies}")

    author = User.all.sample
    post = Post.all.sample
    reply = post.replies.new
    reply.author = author
    reply.created_at = random_time_between_now_and([post.created_at, author.created_at].max)
    reply.body = random_body_with_whitespace(6)
    reply.posted_anonymously = rand(10) == 0

    reply.save
    Subscription.find_or_create_by(user_id: author.id, post_id: post.id)
  end

  puts "\n"
  all_posts = Post.all
  all_posts_count = all_posts.count

  all_posts.each_with_index do |post, post_idx|
    print_inline("Post: #{post_idx + 1} / #{all_posts_count}")

    view_count = case rand(10)
    when 0..3 then rand(30)
    when 4..5 then rand(70)
    when 6..9 then rand(100)
    when 10 then rand(1000)
    end

    view_count.times do |view_idx|
      print_inline("Post: #{post_idx + 1} / #{all_posts_count} - Views: #{view_count - view_idx} / #{view_count}")
      view = post.views.new
      viewer = User.all.sample
      view.viewed_by = viewer
      view.created_at = random_time_between_now_and([post.created_at, viewer.created_at].max)

      view.save
    end
  end
end
