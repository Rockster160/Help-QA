every_hour = "0 * * * *"

cron_jobs = [
  # {
  #   name:  "Deactivate Users",
  #   class: "DeactivateUserWorker",
  #   cron:  every_hour
  # }
]

Sidekiq::Cron::Job.load_from_array! cron_jobs
