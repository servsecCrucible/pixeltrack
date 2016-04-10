require 'sinatra'
require 'json'
require_relative 'config/environments'
require_relative 'models/init'

# Configuration of Pixel tracker API
class PixelTrackerApp < Sinatra::Base
  before do
    host_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    @request_url = URI.join(host_url, request.path.to_s)
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

=begin
  get '/api/v1/pixels/?' do
    content_type 'application/json'
    id_list = Pixel.all

    { pixel_id: id_list }.to_json
  end

  get '/api/v1/pixels/:id.json' do
    content_type 'application/json'

    begin
      { pixel: Pixel.find(params[:id]) }.to_json
    rescue => e
      status 404
      logger.info "FAILED to GET pixel: #{e.inspect}"
    end
  end

  get '/api/v1/pixels/:id/views' do
    content_type 'text/plain'

    begin
      Base64.strict_decode64 Pixel.find(params[:id]).views
    rescue => e
      status 404
      e.inspect
    end
  end

  post '/api/v1/pixels/?' do
    content_type 'application/json'

    begin
      new_data = JSON.parse(request.body.read)
      new_pixel = Pixel.new(new_data)
      if new_pixel.save
        logger.info "NEW PIXEL STORED: #{new_pixel.id}"
      else
        halt 400, "Could not store pixel: #{new_pixel}"
      end

      redirect '/api/v1/pixels/' + new_pixel.id + '.json'
    rescue => e
      status 400
      logger.info "FAILED to create new pixel: #{e.inspect}"
    end
  end
=end
end
