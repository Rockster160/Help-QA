class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def new_obj?
    if respond_to?(:created_at) && respond_to?(:updated_at)
      created_at == updated_at
    else
      new_record?
    end
  end

  def delay(method)
    return send(method) if Rails.env.test?
    # method arrives as a Symbol; Sidekiq 7's strict_args! rejects those.
    DelayWorker.perform_in(5.seconds, self.class.name, self.id, method.to_s)
  end
end
