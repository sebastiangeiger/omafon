#!/usr/bin/env ruby
require_relative '../app/server'
require 'yaml'
path = File.join(File.dirname(__FILE__), '..', 'data', 'test_users.yml')
stored_users = YAML::load_file(path)
users = UserCollection.new
stored_users.each {|user| users.create_user(user)}
puts "- Loaded #{users.size} users -"
domain_model = DomainModel.new(users: users)
server = Server.new
server.start(domain_model, foreground: true, port: 8888)
