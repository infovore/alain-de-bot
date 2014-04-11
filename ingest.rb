#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require 'yaml'
Bundler.require(:default)

PATH_PREFIX = File.expand_path(File.dirname(__FILE__))

config = YAML.load(File.read(PATH_PREFIX + "/creds.yml"))

DB = Sequel.sqlite('alain_de_bot.db')

%w{consumer_key consumer_secret access_token access_token_secret}.each do |key|
  Object.const_set(key.upcase, config["config"][key])
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.access_token = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end

user_name = 'alaindebotton' 
tweets = [] 

(1..16).each do |page| 
  client.user_timeline(user_name, :page => page, :count => 200).each do |tweet| 
    puts "Found tweet"
    p tweet.text
    tweets << tweet
  end 
end 

tweets.each do |tweet|
  unless DB[:existing_tweets].first(:id => tweet.id)
    DB[:existing_tweets].insert(:id => tweet.id,
                                :created_at => tweet.created_at,
                                :content => tweet.text)
  end
end
