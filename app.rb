require 'sinatra'
require 'sinatra/reloader'

class HelloWorldApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    # Enable code reloading
    also_reload File.expand_path('../*.rb', __FILE__)
    also_reload File.expand_path('../views/**/*.erb', __FILE__)
    enable :reloader
    set :reload_templates, true
  end

  configure do
    set :bind, '0.0.0.0'
    set :port, 3000
  end

  get '/' do
    erb :index
  end

  # Add this new route without rebuilding
  get '/test' do
    'This is a new route - no rebuild needed!'
  end

  # API endpoint example
  get '/api/status' do
    content_type :json
    { status: 'ok', time: Time.now }.to_json
  end
end

# Run the application
run HelloWorldApp.run! if __FILE__ == $0 