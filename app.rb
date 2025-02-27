require 'sinatra'
require 'sinatra/reloader'

class HelloWorldApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload './views/**/*.erb'  # Also reload view files
  end

  configure do
    set :bind, '0.0.0.0'
    set :port, 3000
  end

  get '/' do
    erb :index
  end

  # API endpoint example
  get '/api/status' do
    content_type :json
    { status: 'ok', time: Time.now }.to_json
  end
end

if __FILE__ == $0
  HelloWorldApp.run!
end 