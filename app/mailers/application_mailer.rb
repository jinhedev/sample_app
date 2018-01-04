class ApplicationMailer < ActionMailer::Base
  default from: "noreply@example.com" # use actual emails server in production
  layout 'mailer'
end
