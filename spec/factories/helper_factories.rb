FactoryBot.define do
  sequence :email do |n|
    "person#{n}@email.com"
  end

  sequence :username do
    Faker::Internet.username(specifier: 4..20)
  end

  sequence :password do
    "password"
  end

  sequence :body do
    raw_body = Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: rand(3))
    body_pieces = raw_body.split(". ")
    body_pieces.map do |body_piece|
      "#{body_piece}. " + ("\n"*rand(3))
    end.join("")
  end
end
