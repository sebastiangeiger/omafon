require 'capybara/rspec'
require 'capybara/poltergeist'
require 'websocket-eventmachine-client'
require_relative '../integration/test_client'
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
    users.create_user(email: 'other_user@email.com', password: 'other')
    server.start(domain_model)
  end

  it 'lets you sign in' do
    visit '/'
    expect(page).to have_css "#loginWidget"
    fill_in 'email', :with => 'test@email.com'
    fill_in 'password', :with => 'testing'
    click_on 'Sign in'
    expect(page.find("#notifications li")).to have_content "Signed In"
    expect(page).to have_css "#contactList"
    expect(page).to_not have_css "#loginWidget"
  end

  context 'with another user already signed in' do
    let(:client) do
      client = OmaFon::TestClient.new({verbose: true})
    end
    it 'shows that user in the contacts' do
      thread = Thread.new do
        client.run do |socket|
          socket.send(JSON.dump({type: "user/sign_in",
                                 email: "other_user@email.com",
                                 password: "other"}))
        end
      end
      sleep(1)
      visit '/'
      fill_in 'email', :with => 'test@email.com'
      fill_in 'password', :with => 'testing'
      click_on 'Sign in'
      expect(page.find("#contactList")).to have_content "other_user@email.com"
      thread.kill
    end
  end
end
