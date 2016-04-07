require 'sinatra'
require 'json'
require 'base64'
require_relative 'models/pixel'

# Configuration of Pixel tracker API
class PixelTrackerApp < Sinatra::Base
  before do
    Pixel.setup
  end

  get '/?' do
    'Welcome to Servesec Crucible Pixeltrack service'
  end
end

