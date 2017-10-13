HelpBot = User.by_username("HelpBot") if ActiveRecord::Base.connection.table_exists?("users")
