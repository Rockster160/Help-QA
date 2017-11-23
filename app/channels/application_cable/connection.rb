module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", current_user.try(:username) || "Guest"
    end

    protected

    def find_verified_user # this checks whether a user is authenticated with devise
      if verified_user = env['warden'].user
        Sherlock.acting_user = verified_user
        Sherlock.acting_ip = verified_user.try(:super_ip) || request.env['HTTP_X_REAL_IP'] || request.env['REMOTE_ADDR']
        verified_user
      end
    end
  end
end
