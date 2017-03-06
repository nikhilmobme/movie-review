require 'action_mailer'
require 'net/smtp'
require 'active_support'
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :authentication       => :login,
  :user_name            => "moviereview2255@gmail.com",
  :password             => "admin@moviereview",
  :enable_starttls_auto => true
}

class Mailer < ActionMailer::Base
  def awesome_email(details)
    @to     = details[:to]
    @from   = details[:from]
    subject = details[:subject]

    mail( :to      => "#{@to}",
          :from    => "#{@from}",
          :subject => subject) do |format| 
    	    format.html
          end 
  end 
                     
  def caller(email)
    details = { :to =>email, from: 'moviereview2255@gmail.com', subject: 'Welcome to Movie Review!' }
    ActionMailer::Base.view_paths= File.dirname("mailer/")
    email = Mailer.awesome_email( details )
    email.deliver
  end  
end
File.foreach('out.txt') do |row|
  mail=Mailer.new
  mail.caller(row)
end




