# coding: utf-8
require 'slack-ruby-client'

#tokenの設定
file = File.open("token.txt","r")
TOKEN = file.read.strip()

Slack.configure do |config|
	  config.token = TOKEN
		  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new

client.auth_test

#client.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', as_user: true)
#client.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', as_user: false)
#client.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', username: "yubot", as_user: false, icon_emoji: ":3:")

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  case data.text
  when 'bot hi' then
    client.message channel: data.channel, text: "Hi <@#{data.user}>!"
  when /^bot/ then
    client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
  end
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!