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
    # TODO: show all routes as json with links
  end

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
      new_config = Pixel.new(new_data)
      if new_config.save
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
end
