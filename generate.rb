#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "#{File.dirname(__FILE__)}/lib/array.rb"
require "#{File.dirname(__FILE__)}/lib/markov_chain.rb"
Bundler.require(:default)

DB = Sequel.sqlite('alain_de_bot.db')

tweets = DB[:existing_tweets]
text = tweets.map {|t| t[:content]}.join(" ")

to_be_posted = DB[:to_be_posted]
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
