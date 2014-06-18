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
  before(:each) do
    users.create_user(email: 'test@email.com', password: 'testing')
    server.start(domain_model)
  end

  it 'does something' do
    visit '/'
    expect(page).to have_content 'Hello from HTML'
    expect(page).to have_content 'Hello from WebSockets'
    expect(page).to have_content 'Hello from React'
  end

  # it 'lets you sign in' do
  #   visit '/'
  #   fill_in 'Email', :with => 'test@email.com'
  #   fill_in 'Password', :with => 'testing'
  #   click_on 'Sign in'
  # end
end
