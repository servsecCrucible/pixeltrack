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

  get '/api/v1/campaigns/?' do
    content_type 'application/json'
    JSON.pretty_generate(data: Campaign.all)
  end

  get '/api/v1/campaigns/:id' do
    content_type 'application/json'

    id = params[:id]
    campaign = Campaign[id]
    trackers = campaign ? Campaign[id].trackers : []

    if campaign
      JSON.pretty_generate(data: campaign, relationships: trackers)
    else
      halt 404, "PROJECT NOT FOUND: #{id}"
    end
  end

  post '/api/v1/campaigns/?' do
    begin
      new_data = JSON.parse(request.body.read)
      saved_campaign = Campaign.create(new_data)
    rescue => e
      logger.info "FAILED to create new campaign: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', saved_campaign.id.to_s).to_s

    status 201
    headers('Location' => new_location)
  end

  get '/api/v1/campaigns/:id/trackers/?' do
    content_type 'application/json'

    campaign = Campaign[params[:id]]

    JSON.pretty_generate(data: campaign.trackers)
  end

  get '/api/v1/campaigns/:campaign_id/trackers/:id/?' do
    content_type 'application/json'

    begin
      doc_url = URI.join(@request_url.to_s + '/', 'document')
      tracker = Tracker
                .where(campaign_id: params[:campaign_id], id: params[:id])
                .first
      halt(404, 'Tracker not found') unless tracker
      JSON.pretty_generate(data: {
                             tracker: tracker,
                             links: { document: doc_url }
                           })
    rescue => e
      status 400
      logger.info "FAILED to process GET tracker request: #{e.inspect}"
      e.inspect
    end
  end

  get '/api/v1/campaigns/:campaign_id/trackers/:id/document' do
    content_type 'text/plain'

    begin
      Tracker
        .where(campaign_id: params[:campaign_id], id: params[:id])
        .first
        .document
    rescue => e
      status 404
      e.inspect
    end
  end

  post '/api/v1/campaign/:campaign_id/trackers/?' do
    begin
      new_data = JSON.parse(request.body.read)
      campaign = Campaign[params[:campaign_id]]
      saved_tracker = campaign.add_tracker(new_data)
    rescue => e
      logger.info "FAILED to create new tracker: #{e.inspect}"
      halt 400
    end

    status 201
    new_location = URI.join(@request_url.to_s + '/', saved_tracker.id.to_s).to_s
    headers('Location' => new_location)
  end

  #   get '/api/v1/pixels/?' do
  #     content_type 'application/json'
  #     id_list = Pixel.all
  #
  #     { pixel_id: id_list }.to_json
  #   end
  #
  #   get '/api/v1/pixels/:id.json' do
  #     content_type 'application/json'
  #
  #     begin
  #       { pixel: Pixel.find(params[:id]) }.to_json
  #     rescue => e
  #       status 404
  #       logger.info "FAILED to GET pixel: #{e.inspect}"
  #     end
  #   end
  #
  #   get '/api/v1/pixels/:id/views' do
  #     content_type 'text/plain'
  #
  #     begin
  #       Base64.strict_decode64 Pixel.find(params[:id]).views
  #     rescue => e
  #       status 404
  #       e.inspect
  #     end
  #   end
  #
  #   post '/api/v1/pixels/?' do
  #     content_type 'application/json'
  #
  #     begin
  #       new_data = JSON.parse(request.body.read)
  #       new_pixel = Pixel.new(new_data)
  #       if new_pixel.save
  #         logger.info "NEW PIXEL STORED: #{new_pixel.id}"
  #       else
  #         halt 400, "Could not store pixel: #{new_pixel}"
  #       end
  #
  #       redirect '/api/v1/pixels/' + new_pixel.id + '.json'
  #     rescue => e
  #       status 400
  #       logger.info "FAILED to create new pixel: #{e.inspect}"
  #     end
  #   end
end
