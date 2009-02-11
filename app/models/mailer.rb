class Mailer < ActionMailer::Base
  def forgot_password(email_id, password)
    recipients email_id
    from       "noreply@presentah.com"
    subject    "Change of Password"
    body       :password => password
  end
end