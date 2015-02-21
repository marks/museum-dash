$: << File.expand_path('./lib', File.dirname(__FILE__))
require 'dashing-contrib'
require 'dashing'
DashingContrib.configure

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application