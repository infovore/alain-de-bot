#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
Bundler.require(:default)

DB = Sequel.sqlite('alain_de_bot.db')

DB.create_table :existing_tweets do
  primary_key :id
  String :content, :null => false
  DateTime :created_at
  index :created_at
end

DB.create_table :to_be_posted do
  primary_key :id
  String :content, :null => false
  DateTime :created_at
  DateTime :posted_at
  index :created_at
end


