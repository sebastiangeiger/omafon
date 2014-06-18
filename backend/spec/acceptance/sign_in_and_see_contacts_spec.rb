require 'capybara/rspec'
require 'capybara/poltergeist'
require_relative '../../../frontend/file_server'
require_relative '../../app/server'

Capybara.app = Sinatra::Application
Capybara.javascript_driver = :poltergeist

describe "Sign in and see online contacts", type: :feature, js: true do
  let(:users) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: users) }
  let(:server) { Server.new }
  after(:each) { server.kill }
  it 'does something' do
    server.start(domain_model)
    visit '/'
    expect(page).to have_content 'Hello from HTML'
    expect(page).to have_content 'Hello from JS'
    expect(page).to have_content 'Hello from WebSockets'
  end
end
