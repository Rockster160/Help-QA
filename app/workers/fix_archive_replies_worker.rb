class FixArchiveRepliesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    user = User.find_by(username: "Unclaimed")
    250.times do
      @post = user.posts.order(:updated_at).first
      @step = 0
      next if @post.blank?
      next save_post! if @post.replies.none?
      handle_post
    end
  end

  def handle_post
    first_reply = @post.replies.order(created_at: :asc, id: :asc).first
    @step += 1
    return set_reply!(first_reply) if correct_reply?(first_reply)

    last_reply = @post.replies.order(created_at: :asc, id: :asc).last
    @step += 1
    return set_reply!(last_reply) if correct_reply?(last_reply)

    found_reply = @post.replies.joins(:post).find_by("REGEXP_REPLACE(replies.body, '[^\\wDdpx]', '', 'g') LIKE REGEXP_REPLACE(posts.body, '[^\\wDdpx]', '', 'g')||'%'")
    @step += 1
    return set_reply!(found_reply) if found_reply.present?

    clean_body = @post.body.gsub(/[^\wDdpx]/, "")
    if clean_body.length > 10
      half_body = clean_body.split("").in_groups(2).first.join("")
      found_reply = @post.replies.joins(:post).find_by("REGEXP_REPLACE(replies.body, '[^\\wDdpx]', '', 'g') LIKE ?||'%'", half_body)
      @step += 1
      return set_reply!(found_reply) if found_reply.present?
    end

    @step += 1
    return if @post.reload.author.username != "Unclaimed"
    puts "Failed post: #{@post.id}".colorize(:red)
    save_post!
  end

  def correct_reply?(reply)
    reply.body.gsub(/[^\wDdpx]/, "").include?(@post.body.gsub(/[^\wDdpx]/, ""))
  end

  def set_reply!(reply)
    @post.body = reply.body
    @post.author_id = reply.author_id
    save_post!
    reply.destroy
  end

  def save_post!
    @post.updated_at = DateTime.current
    @post.save(validate: false)
  end
end
