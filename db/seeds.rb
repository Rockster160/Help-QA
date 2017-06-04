def random_time_between_now_and(this_time)
  rand(1.hour.ago..this_time)
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
  prev_num = num.to_i - 1
  prev_num.to_s.length.times { print "\b" }
  print num
end

start_date = 5.years.ago
users = 1000
posts = 300
comments = 2000

puts "\nGenerating People...\n"
Rando.people(users).each_with_index do |person, person_idx|
  print_next_number(users - person_idx)
  u = User.new
  u.skip_confirmation!
  email_with_idx = person.email.split("@").join("#{User.count}@")

  u.email = email_with_idx
  u.password = "password"

  created = random_time_between_now_and(start_date)
  u.created_at = created
  u.remember_created_at = created

  u.username = "#{User.count}#{person.login.username}"
  u.avatar_url = rand(3) == 0 ? person.picture.thumbnail : nil

  u.save

  location = u.location.new
  location.ip = (0..255).to_a.sample(4).join(".")
  location.city = person.location.city
  location.zip_code = person.location.postcode

  location.save
end

puts "\nGenerating Posts...\n"
posts.times do |post_idx|
  print_next_number(posts - post_idx)

  author = User.all.sample
  post = author.posts.new
  post.created_at = random_time_between_now_and(author.created_at)
  post.body = random_body_with_whitespace(10)
  post.posted_anonymously = rand(4) == 0

  post.save
end

puts "\nGenerating Post Comments...\n"
comments.times do |comment_idx|
  print_next_number(comments - comment_idx)

  author = User.all.sample
  post = Post.all.sample
  comment = post.comments.new
  comment.author = author
  comment.created_at = random_time_between_now_and([post.created_at, author.created_at].max)
  comment.body = random_body_with_whitespace(6)
  comment.posted_anonymously = rand(10) == 0

  comment.save
end

puts "\nGenerating Post Views...\n"
all_posts = Post.all
all_posts_count = all_posts.count

all_posts.each_with_index do |post, post_idx|
  puts "Post: #{post_idx + 1} / #{all_posts_count}\nViews:"

  view_count = case rand(10)
  when 0..3 then rand(30)
  when 4..5 then rand(70)
  when 6..9 then rand(100)
  when 10 then rand(1000)
  end

  view_count.times do |view_idx|
    print_next_number(view_count - view_idx)
    view = post.views.new
    viewer = User.all.sample
    view.viewed_by = viewer
    view.created_at = random_time_between_now_and([post.created_at, viewer.created_at].max)

    view.save
  end
end
