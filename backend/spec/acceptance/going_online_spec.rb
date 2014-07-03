require_relative 'spec_helper'

describe "Going online", type: :feature, js: true do

  let(:users) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: users) }
  let(:other_user) { OmaFon::TestClient.new }
  let(:server) { Server.new }
  after(:each) { server.kill }

  before(:each) do
    users.create_user(email: 'test@email.com', password: 'testing')
    users.create_user(email: 'other_user@email.com', password: 'other')
    server.start(domain_model)
  end

  context 'when another user is already signed in' do
    before(:each) do
      other_user_thread = Thread.new do
        other_user.run do |socket|
          socket.send(JSON.dump({type: "user/sign_in",
                                 email: "other_user@email.com",
                                 password: "other"}))
        end
      end
      sleep(0.3)
    end
    it 'shows that user in the contacts' do
      visit '/'
      fill_in 'email', :with => 'test@email.com'
      fill_in 'password', :with => 'testing'
      click_on 'Sign in'
      expect(page).to have_css "#contactList"
      expect(page.find("#contactList")).to have_content "other_user@email.com"
    end
  end

  context 'when another user signs in after you' do
    before(:each) do
      visit '/'
      fill_in 'email', :with => 'test@email.com'
      fill_in 'password', :with => 'testing'
      click_on 'Sign in'
      expect(page).to have_css "#contactList"
    end
    it 'shows that user in the contacts' do
      other_user_thread = Thread.new do
        other_user.run do |socket|
          socket.send(JSON.dump({type: "user/sign_in",
                                 email: "other_user@email.com",
                                 password: "other"}))
        end
      end
      expect(page.find("#contactList")).to have_content "other_user@email.com"
    end
  end
end
