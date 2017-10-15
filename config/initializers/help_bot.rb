def helpbot
  $helpbot ||= User.by_username("HelpBot")
end
