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

  get '/api/v1/?' do
    apidoc = {
      '/api/v1/' => {
        'get' => {
          'parameters' => 'None',
          'status' => '200',
          'data' => 'help'
        }
      },
      '/api/v1/pixels/' => {
        'get' => {
          'parameters' => 'None',
          'status' => '200',
          'data' => 'return the list of pixel ids'
        },
        'post' => {
          'parameters' => {
            'id' => 'id of the new pixel (optional)',
            'label' => 'label of the pixel'
          },
          'status' => '300',
          'data' => 'redirect to the new created pixel'
        }
      },
      '/api/v1/pixels/:id.json' => {
        'get' => {
          'parameters' => 'None',
          'status' => '200',
          'data' => 'pixel details'
        }
      }
    }
    apidoc.to_json
  end
end

