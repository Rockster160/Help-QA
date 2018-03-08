every_15_seconds = "* * * * *"
every_hour = "0 * * * *"

cron_jobs = [
  # {
  #   name:  "Deactivate Users",
  #   class: "DeactivateUserWorker",
  #   cron:  every_hour
  # }
]

if Rails.env.archive?
  cron_jobs += [
    {
      name: "Fix Replies",
      class: "FixArchiveRepliesWorker",
      cron: every_15_seconds
    }
  ]
end

Sidekiq::Cron::Job.load_from_array! cron_jobs
