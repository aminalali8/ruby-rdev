require './app'

# Disable host checking at the Rack level
use Rack::Protection, except: [:remote_token, :host_authorization, :path_traversal]

run HelloWorldApp 