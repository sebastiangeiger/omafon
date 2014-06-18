require 'capybara/rspec'
require 'capybara/poltergeist'
require_relative '../../../frontend/file_server'

Capybara.app = Sinatra::Application
Capybara.javascript_driver = :poltergeist

describe "Sign in and see online contacts", type: :feature, js: true do
  it 'does something' do
    visit '/'
    expect(page).to have_content 'Hello from HTML'
    expect(page).to have_content 'Hello from JS'
  end
end
