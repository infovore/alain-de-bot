#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "#{File.dirname(__FILE__)}/lib/array.rb"
require "#{File.dirname(__FILE__)}/lib/markov_chain.rb"
Bundler.require(:default)

DB = Sequel.sqlite('alain_de_bot.db')

def generate_items
  tweets = DB[:existing_tweets]
  to_be_posted = DB[:to_be_posted]
  text = tweets.map {|t| t[:content]}.join(" ")

  100.times do
    mc = MarkovChain.new(text)
    # if it's less than 141 chars, tweet it
    string = mc.sentences(1).capitalize
    # otherwise re-generate until it fits
    while string.size > 140 && !to_be_posted.first(:content => string)
      string = mc.sentences(1).capitalize
    end
    
    to_be_posted.insert(:content => string, :created_at => Time.now)
  end
end


PATH_PREFIX = File.expand_path(File.dirname(__FILE__))
config = YAML.parse(File.read(PATH_PREFIX + "/creds.yml"))

%w{consumer_key consumer_secret access_token access_token_secret}.each do |key|
  Object.const_set(key.upcase, config["config"][key].value)
end

Twitter.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
end

to_be_posted = DB[:to_be_posted]

# one in 120 times, generate a chain
if(rand(120) < 1)
  if !to_be_posted.first(:posted_at => nil)
    # generate some more
    puts "generating items"
    generate_items
  end
  #Twitter.update(to_be_posted.first.content)
  first_tweet = to_be_posted.first(:posted_at => nil)
  puts "posting tweet #{first_tweet[:content]}"
  to_be_posted.where(:id => first_tweet[:id]).update(:posted_at => Time.now)
end

