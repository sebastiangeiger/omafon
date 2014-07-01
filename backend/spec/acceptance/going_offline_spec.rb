require_relative 'spec_helper'

describe "Going offline", type: :feature, js: true do
  let(:users) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: users) }
  let(:server) { Server.new }
  after(:each) { server.kill }
  before(:each) do
    users.create_user(email: 'test@email.com', password: 'testing')
    users.create_user(email: 'other_user@email.com', password: 'other')
    server.start(domain_model)
  end

  context 'when I am signed in' do
    let(:other_user) do
      OmaFon::TestClient.new({verbose: false})
    end

    before(:each) do
      visit '/'
      fill_in 'email', :with => 'test@email.com'
      fill_in 'password', :with => 'testing'
      click_on 'Sign in'
      expect(page).to have_css "#contactList"
    end

    it 'removes the other user from the contact list' do
      seen_other_user = false
      Thread.abort_on_exception=true
      other_user_thread = Thread.new do
        other_user.run do |socket|
          socket.send(JSON.dump({type: "user/sign_in",
                                 email: "other_user@email.com",
                                 password: "other"}))
          socket.close_if do
            seen_other_user
          end
        end
      end
      expect(page.find("#contactList")).to have_content "other_user@email.com"
      seen_other_user = true
      expect(page.find("#contactList")).to_not have_content "other_user@email.com"
    end
  end
end

