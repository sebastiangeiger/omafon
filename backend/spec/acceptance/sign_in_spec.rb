require_relative 'spec_helper'

describe "Sign in", type: :feature, js: true do

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
end
