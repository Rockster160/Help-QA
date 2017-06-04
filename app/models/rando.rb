class Rando
  class << self

    def people(count=1)
      json_str = RestClient.get("https://randomuser.me/api/?results=#{count}").body
      persons_json = JSON.parse(json_str)["results"]
      people = []
      persons_json.each do |person_json|
        person = struct_from_json(person_json)
        person.last_login_at = rand(1.week.ago..1.week.from_now)
        people << person
      end
      people
    end

    def posts(count)
      authors = people(count)
      count.times.map do
        post_json = {
          author: authors.sample,
          body: Faker::Lorem.paragraph(2, true, 6),
          created_at: rand(1.week.ago..1.week.from_now),
          replies: rand(10),
          views: rand(100) + 10
        }
        struct_from_json(post_json)
      end
    end

    def struct_from_json(hash)
      obj = OpenStruct.new
      hash.each do |key, val|
        if val.is_a?(Hash)
          new_obj = struct_from_json(val)
          obj.send("#{key}=", new_obj)
        else
          obj.send("#{key}=", val)
        end
      end
      obj
    end

  end
end
