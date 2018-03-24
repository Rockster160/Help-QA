class DeliverOldInvitesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    File.open("contact").read.split("\n").each do |email|
      puts "Delivering to: #{email}"
      # UserMailer.historical_invite(email).deliver
    end
  end
end
