class DelayWorker
  include Sidekiq::Worker

  def perform(klass, id, method)
    klass.constantize.find(id).send(method)
  end

end
