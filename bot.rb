# coding: utf-8
require 'slack-ruby-client'

def slot(cnt = 1, bonus = false)
  yaku = [":3:",":tangerine:",":fish:"]
  str = ""
  index = Array.new()
  for c in 1..cnt
    for i in 0..2 do
      index[i] = rand(yaku.count)
    end
    if(bonus==true)
      if(rand(3)==1)
        index[1] = index[0]
        index[2] = index[0]
      end
    end
    for i in 0..2 do
      str += yaku[index[i]]
    end
    if(index[0] == index[1] && index[1] == index[2])
      str += ":5000chouen:"
    end
    str += "\n"
  end
  return str
end

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

channels = {}
channelsID = {}
users = {}
usersID = {}

# 接続時
client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: 'Hello World', username: "yubot", as_user: false, icon_emoji: ":3:")
  
  channelList = clientWeb.channels_list["channels"]
  userList = clientWeb.users_list["members"]
  for channel in channelList
    channels.store(channel["name"],channel)
    channelsID.store(channel["id"],channel["name"])
  end
  for user in userList
    users.store(user["name"],user)
    usersID.store(user["id"],user["name"])
  end
end

# 誰かが発言したとき
client.on :message do |data|
  if channelsID[data["channel"]] == "yu3-dev-memo" && !data.has_key?(:bot_id)
    case data.text
    when 'bot hi' then
      client.message channel: data.channel, text: "Hi <@#{data.user}>!"
    when 'bot help' then
      clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: '"bot slot 10"で10連スロットが回せるよ', username: "yubot", as_user: false, icon_emoji: ":3:")
    when 'bot slot', 'スロット' then
      slotStr = slot()
      clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: slotStr, username: "yubot", as_user: false, icon_emoji: ":3:")  
    when /bot slot \d+/
      m = /bot slot (\d+)/.match(data.text)
      puts m[1]
      slotCnt = m[1].to_i
      if(0<slotCnt && slotCnt<=10)
        slotStr = slot(slotCnt)
        clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: slotStr, username: "yubot", as_user: false, icon_emoji: ":3:")  
      elsif (slotCnt>10)
        clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: "一度のスロットは10連まで!", username: "yubot", as_user: false, icon_emoji: ":3:")
      elsif
        clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: "正の回数じゃないと回せないよ!", username: "yubot", as_user: false, icon_emoji: ":3:")        
      end
    when /bot slot bonus \d+/
      m = /bot slot bonus (\d+)/.match(data.text)
      puts m[1]
      slotCnt = m[1].to_i
      if(0<slotCnt && slotCnt<=10)
        slotStr = slot(slotCnt, true)
        clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: slotStr, username: "yubot", as_user: false, icon_emoji: ":3:")  
      elsif (slotCnt>10)
        clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: "一度のスロットは10連まで!", username: "yubot", as_user: false, icon_emoji: ":3:")
      elsif
        clientWeb.chat_postMessage(channel: '#yu3-dev-memo', text: "正の回数じゃないと回せないよ!", username: "yubot", as_user: false, icon_emoji: ":3:")        
      end
    when /^bot/ then
      client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
    end
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