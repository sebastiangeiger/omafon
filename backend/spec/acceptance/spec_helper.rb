require 'capybara/rspec'
require 'capybara/poltergeist'
require 'websocket-eventmachine-client'
require_relative '../integration/test_client'
require_relative '../../../frontend/file_server'
require_relative '../../app/server'

Capybara.app = Sinatra::Application

module Capybara::Poltergeist
  class Client
    private
    def redirect_stdout
      prev = STDOUT.dup
      prev.autoclose = false
      $stdout = @write_io
      STDOUT.reopen(@write_io)

      prev = STDERR.dup
      prev.autoclose = false
      $stderr = @write_io
      STDERR.reopen(@write_io)
      yield
    ensure
      STDOUT.reopen(prev)
      $stdout = STDOUT
      STDERR.reopen(prev)
      $stderr = STDERR
    end
  end
end

class WarningSuppressor
  class << self
    IGNORED = [
      /You are using the in-browser JSX transformer/,
      /CoreText performance note:/,
      /Each child in an array should have a unique "key" prop/ #TODO: I should actually fix that
    ]
    def matches_ignored?(message)
      IGNORED.select{|regex| message =~ regex}.any?
    end
    def write(message)
      if matches_ignored?(message)  then
        0
      else
        puts(message)
        1
      end
    end
  end
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: WarningSuppressor)
end
Capybara.javascript_driver = :poltergeist

