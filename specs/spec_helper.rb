ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

Dir.glob('./{config,models,services,controllers,lib}/init.rb').each do |file|
  require file
end

include Rack::Test::Methods

def app
  PixelTrackerAPI
end

def invalid_id(resource)
  (resource.max(:id) || 0) + 1
end
