class UpdatePopularPostWorker
  include Sidekiq::Worker

  def perform
    Rails.cache.fetch("currently_popular_post", force: true) { Post.currently_popular }
  end
end
