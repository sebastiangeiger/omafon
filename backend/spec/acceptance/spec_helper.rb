require 'capybara/rspec'
require 'capybara/poltergeist'
require 'websocket-eventmachine-client'
require_relative '../integration/test_client'
require_relative '../../../frontend/file_server'
require_relative '../../app/server'

Capybara.app = Sinatra::Application
Capybara.javascript_driver = :poltergeist
