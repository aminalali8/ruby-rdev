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
    # Remove explicit host binding to allow Kubernetes to handle it
    set :port, ENV.fetch('PORT', 3000)
    set :bind, '0.0.0.0'
    # Disable Sinatra's built-in protection
    disable :protection
    set :public_folder, 'public'
    enable :logging
    set :show_exceptions, true
    set :environment, :production
    set :host_authorization, { permitted_hosts: [] }
  end

  before do
    # Allow requests from any host
    headers 'Access-Control-Allow-Origin' => '*'
  end

  # Add favicon route to handle the request explicitly
  get '/favicon.ico' do
    204 # return a "No Content" status code
  end

  get '/' do
    erb :index
  end

  get '/test' do
    'This is a new route - no rebuild needed!'
  end

  # API endpoint example
  get '/api/status' do
    content_type :json
    { status: 'ok', time: Time.now }.to_json
  end

  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end
end

run HelloWorldApp.run! if __FILE__ == $0 