#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
Bundler.require(:default)

PATH_PREFIX = File.expand_path(File.dirname(__FILE__))

config = YAML.load(File.read(PATH_PREFIX + "/creds.yml"))

DB = Sequel.sqlite('alain_de_bot.db')

%w{consumer_key consumer_secret access_token access_token_secret}.each do |key|
  Object.const_set(key.upcase, config["config"][key])
end

Twitter.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
end

user_name = 'alaindebotton' 
tweets = [] 

(1..16).each do |page| 
  Twitter.user_timeline(user_name, :page => page, :count => 200).each do |tweet| 
    tweets << tweet 
  end 
end 

tweets.each do |tweet|
  unless DB[:existing_tweets].first(:id => tweet.id)
    DB[:existing_tweets].insert(:id => tweet.id,
                                :content => tweet.text)
  end
end
