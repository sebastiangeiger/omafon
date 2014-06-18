require 'sinatra'

set :public_folder, File.dirname(__FILE__)
set :port, 3000

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end
