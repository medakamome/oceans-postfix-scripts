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
    File.open("/home/postfix/scripts/oceans-postfix-scripts/config.json") do |file|
       @hash = JSON.load(file)
    end
 end

 def execute
    Slack.configure do |config|
        config.token = @hash['slack_token']
    end

    mail = Mail.new($stdin.read)
=begin
    begin
        open(@out_file, "w") do |f|
            mail = Mail.new($stdin.read)
            f.puts "From:    #{mail.from.first}"
            f.puts "To:      #{mail.to.first}"
            f.puts "Date:    #{mail.date}"
            f.puts "Subject: #{mail.subject}"
            f.puts "Body:\n#{mail.body.decoded.encode("UTF-8", mail.charset)}"
        end
    rescue => e
        exit 1
    end
=end

=begin
    row_body = mail.multipart? ? (mail.text_part ? mail.text_part.decoded : nil) : mail.body.decoded

    decoded_body = NKF.nkf('-w', row_body)
    body = body_to_pobody(decoded_body)
=end

    judge_kapo(mail.subject)

    #subject = mail.subject.split('gbpjpy')
    #body = "#{subject[1]}\n ``` #{body}```"
    #Slack.chat_postMessage(text: body, channel: '#slacktest', username: 'mt4alert')
  end

  def body_to_pobody(body)
    items = body.split('-' * 73)
    return items[0] if items.count >= 1
    nil
  end

  def judge_kapo(subject)
    channel = "#slacktest"
    #USDJPY
    if !(/^(?=.*USD)(?=.*JPY)/ !~ subject) then
        channel = "#usdjpy"
    #EURUSD
    elsif !(/^(?=.*EUR)(?=.*USD)/ !~ subject) then
        channel = "#eurusd"
    #EURJPY
    elsif !(/^(?=.*EUR)(?=.*JPY)/ !~ subject) then
        channel = "#eurjpy"
    #GBPJPY
    elsif !(/^(?=.*GBP)(?=.*JPY)/ !~ subject) then
        channel = "#gbpjpy"
    #GBPUSD
    elsif !(/^(?=.*GBP)(?=.*USD)/ !~ subject) then
        channel = "#gbpusd"
    #AUDJPY
    elsif !(/^(?=.*AUD)(?=.*JPY)/ !~ subject) then
        channel = "#audjpy"
    #NZDJPY
    elsif !(/^(?=.*NZD)(?=.*JPY)/ !~ subject) then
        channel = "#nzdjpy"
    #EURGBP
    elsif !(/^(?=.*EUR)(?=.*GBP)/ !~ subject) then
        channel = "#eurgbp"
    end

    if channel != "" then
        begin
            Slack.chat_postMessage(text: subject, channel: channel, username: "mt4alert")
        rescue => e
            $stderr.puts "[#{e.class}] #{e.message}"
            puts "[#{e.class}] #{e.message}"
        end
    end
  end
end

GetMail.new.execute
