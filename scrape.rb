require 'rubygems'
require 'twitter'
require 'yaml'

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

user_name = 'alaindebotton' 
tweets = [] 

(1..16).each do |page| 
  Twitter.user_timeline(user_name, :page => page, :count => 200).each do 
|tweet| 
    tweets << tweet 
  end 
end 

File.open("tweets.txt") do |f|
  f.write(tweets.join("\n"))
end
