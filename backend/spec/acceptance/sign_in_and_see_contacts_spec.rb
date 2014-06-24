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

  it 'lets you sign in with the right password' do
    visit '/'
    expect(page).to have_css "#loginWidget"
    fill_in 'email', :with => 'test@email.com'
    fill_in 'password', :with => 'testing'
    click_on 'Sign in'
    expect(page.find("#notifications")).to have_content "Signed In"
    expect(page).to have_css "#contactList"
    expect(page).to_not have_css "#loginWidget"
  end

  it 'turns you down with the wrong password' do
    visit '/'
    expect(page).to have_css "#loginWidget"
    fill_in 'email', :with => 'test@email.com'
    fill_in 'password', :with => 'wrongpassword'
    click_on 'Sign in'
    expect(page).to_not have_css "#contactList"
    expect(page).to have_css "#loginWidget"
    expect(page).to have_content "Wrong email/password combination"
  end

  context 'with another user already signed in' do
    let(:other_user) do
      OmaFon::TestClient.new({verbose: false})
    end
    it 'shows that user in the contacts' do
      other_user_thread = Thread.new do
        other_user.run do |socket|
          socket.send(JSON.dump({type: "user/sign_in",
                                 email: "other_user@email.com",
                                 password: "other"}))
        end
      end
      sleep(0.3)
      visit '/'
      fill_in 'email', :with => 'test@email.com'
      fill_in 'password', :with => 'testing'
      click_on 'Sign in'
      expect(page).to have_css "#contactList"
      expect(page.find("#contactList")).to have_content "other_user@email.com"
      other_user_thread.kill
    end
  end
end
