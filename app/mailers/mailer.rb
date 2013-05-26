class Mailer < ActionMailer::Base
  default from: "from@example.com"

  # Sends an e-mail from app/views/mailer/invitation.html.erb
  #
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.mailer.invitation.subject
  #
  
  def invitation(email, service, url)
    @url = url
    @service = service
    @email = email
    mail to: email, subject:"Suncorp Survey"
  end
  
  def newUserEmail(email, password, url)
    @email = email
    @password = password
    @url = url
    mail to: email, subject: "Welcome to Knightcap"
  end
end