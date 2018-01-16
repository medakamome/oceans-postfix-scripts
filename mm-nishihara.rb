#! /usr/bin/ruby
# coding: utf-8
#-------------------------------------------------
# Ruby script to get a mail via alias of postfix.
#-------------------------------------------------
require 'rubygems'
require 'json'
require 'mail'
require 'slack'
require 'nkf'
require 'logger'

class GetMail
 def initialize
    dt = Time.now.strftime("%Y%m%d")
#    @log = Logger.new('/home/postfix/log')
    @out_file = "/home/postfix/log/#{dt}.log"
    File.open("/home/postfix/scripts/oceans-postfix-scripts/config.json") do |file|
       @hash = JSON.load(file)
    end
 end

 def execute
    Slack.configure do |config|
       config.token = @hash['slack_token']
    end
    
    mail = Mail.new($stdin.read)
#=begin
    begin
        open(@out_file, "w") do |f|
#             f.puts "stdin:   #{mail}"
            f.puts "json:    #{@hash['slack_token']}"
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

 #   row_body = mail.multipart? ? (mail.text_part ? mail.text_part.decoded : nil) : mail.body.decoded

#    decoded_body = NKF.nkf('-w', row_body)
 #   body = body_to_pobody(decoded_body)
    body = mail.body.decoded.encode("UTF-8", mail.charset)
    body = body.sub(/加藤　高正/,"XXX")
    
    Slack.chat_postMessage(text: body, channel: '#devpost', username: 'にっしー')
    
  end

  def body_to_pobody(body)
    items = body.split('-' * 73)
    return items[0] if items.count >= 1
    nil
  end
end

#begin
  GetMail.new.execute
#rescue => e
#  exit 1
#end
