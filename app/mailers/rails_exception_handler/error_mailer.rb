if RailsExceptionHandler.configuration.activate? && RailsExceptionHandler.configuration.email?
  class RailsExceptionHandler::ErrorMailer < ApplicationMailer

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.error_mailer.send_error_mail_to_admin.subject
    #
    def send_error_mail_to_admin(info,email)
      @info = JSON.parse(info)
      mail(to: email, subject: 'An error occured on your application')
    end
    
  end
end
