FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@email.com"
  end

  sequence :username do
    Faker::Internet.user_name(4..20)
  end

  sequence :password do
    "password"
  end

  sequence :body do
    raw_body = Faker::Lorem.paragraph(2, true, paragraph_count)
    body_pieces = raw_body.split(". ")
    body_pieces.map do |body_piece|
      body += body_piece + ". " + ("\n"*rand(3))
    end.join("")
  end
end
