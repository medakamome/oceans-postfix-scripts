#! /usr/bin/ruby
# coding: utf-8
#-------------------------------------------------
# Ruby script to get a mail via alias of postfix.
#-------------------------------------------------
require 'mail'
require 'slack'
require 'nkf'

class GetMail
 def initialize
    dt = Time.now.strftime("%Y%m%d")
    @out_file = "/home/postfix/log/#{dt}.log"
 end

 def execute
    Slack.configure do |config|
      config.token = 'xoxp-288774156885-289496027958-297279289409-62e31333077cf2fbe57d501021269742'
    end

    mail = Mail.new($stdin.read)
#    stdin = $stdin.read
#=begin
    begin
        open(@out_file, "w") do |f|
#            mail = Mail.new($stdin.read)
#             f.puts "stdin:   #{mail}"
            f.puts "From:    #{mail.from.first}"
            f.puts "To:      #{mail.to.first}"
            f.puts "Date:    #{mail.date}"
            f.puts "Subject: #{mail.subject}"
            f.puts "Body:\n#{mail.body.decoded.encode("UTF-8", mail.charset)}"
        end
    rescue => e
        exit 1
    end
#=end

    row_body = mail.multipart? ? (mail.text_part ? mail.text_part.decoded : nil) : mail.body.decoded

    decoded_body = NKF.nkf('-w', row_body)
    body = body_to_pobody(decoded_body)
 #  body = mail.body.decoded.encode("UTF-8", mail.charset)
    body = body.sub(/白土光/,"XXX")
 #   body.sub(/光/,"XXX")

    #subject = mail.subject.split('gbpjpy')
    #body = "#{subject[1]}\n ``` #{body}```"
    
    Slack.chat_postMessage(text: body, channel: '#devpost', username: '志摩力男')
    
  end

  def body_to_pobody(body)
    items = body.split('-' * 73)
    return items[0] if items.count >= 1
    nil
  end
end

GetMail.new.execute
