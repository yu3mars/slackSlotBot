# coding: utf-8
require 'slack-ruby-client'

#tokenの設定
file = File.open("token.txt","r")
TOKEN = file.read.strip()

Slack.configure do |config|
	  config.token = TOKEN
		  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

clientWeb = Slack::Web::Client.new

clientWeb.auth_test

#clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', as_user: true)
#clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', as_user: false)
#clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', username: "yubot", as_user: false, icon_emoji: ":3:")

client = Slack::RealTime::Client.new

# 接続時
client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', username: "yubot", as_user: false, icon_emoji: ":3:")
end

# 誰かが発言したとき
client.on :message do |data|
  case data.text
  when 'bot hi' then
    client.message channel: data.channel, text: "Hi <@#{data.user}>!"
  when /^bot/ then
    client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
  end
end

# 接続解除時
client.on :close do |_data|
  puts "Client is about to disconnect"
  clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: 'Bye', username: "yubot", as_user: false, icon_emoji: ":3:")  
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!