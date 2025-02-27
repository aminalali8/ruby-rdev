require 'sinatra'

class HelloWorldApp < Sinatra::Base
  # Configure the application
  configure do
    set :port, 3000  # Ensure this is set to 3000
    set :bind, '0.0.0.0'  # This is important for Docker
  end

  # Define routes
  get '/' do
    erb :index
  end

  get '/api/greeting' do
    content_type :json
    { message: 'Hello, World!', time: Time.now }.to_json
  end
end

# Run the application if this file is executed directly
if __FILE__ == $0
  HelloWorldApp.run!
end 