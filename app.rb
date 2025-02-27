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
    # Start the permissions watcher when the app starts
    permissions_watcher = PermissionsManager.new(File.expand_path('.'))
    permissions_watcher.fix_permissions
    permissions_watcher.start_watcher
    
    # Ensure the watcher is stopped when the app exits
    at_exit do
      permissions_watcher.stop_watcher
    end
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

  # Add this near the top of the class, after the configure blocks
  require_relative 'permissions'
  
  # Add this helper method
  def authorized?
    # In production, you'd want proper authentication
    # This is just a basic example using an env variable
    auth_token = ENV['ADMIN_TOKEN']
    provided_token = request.env['HTTP_X_ADMIN_TOKEN']
    
    auth_token && !auth_token.empty? && auth_token == provided_token
  end

  # Add this new route
  post '/admin/fix-permissions' do
    content_type :json
    
    unless authorized?
      status 401
      return { error: 'Unauthorized' }.to_json
    end

    begin
      PermissionsManager.fix_permissions
      { status: 'success', message: 'Permissions updated successfully' }.to_json
    rescue => e
      status 500
      { status: 'error', message: e.message }.to_json
    end
  end
end

run HelloWorldApp.run! if __FILE__ == $0 