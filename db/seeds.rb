def random_time_between_now_and(this_time)
  rand(1.hour.ago..this_time)
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

puts "Generating People...\n"
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
end
