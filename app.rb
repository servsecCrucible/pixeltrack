require 'sinatra'
require 'json'
require_relative 'config/environments'
require_relative 'models/init'

# Configuration of Pixel tracker API
class PixelTrackerAPI < Sinatra::Base
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

        campaign = Campaign.where(id: params[:id]).first
        trackers = campaign ? campaign.trackers : []

        if campaign
            JSON.pretty_generate(data: campaign, relationships: trackers)
        else
            halt 404, "PROJECT NOT FOUND: #{params[:id]}"
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
        campaign = Campaign.where(id: params[:id]).first
        JSON.pretty_generate(data: campaign.trackers)
    end

    get '/api/v1/campaigns/:campaign_id/trackers/:id/?' do
        content_type 'application/json'

        begin
            doc_url = URI.join(@request_url.to_s + '/', 'json')
            tracker = Tracker
                      .where(campaign_id: params[:campaign_id], id: params[:id])
                      .first
            halt(404, 'Tracker not found') unless tracker
            JSON.pretty_generate(data: {
                                     tracker: tracker,
                                     links: { item_url: doc_url }
                                 })
        rescue => e
            status 400
            logger.info "FAILED to process GET tracker request: #{e.inspect}"
            e.inspect
        end
    end

    get '/api/v1/campaigns/:campaign_id/trackers/:id/json' do
        content_type 'text/plain'

        begin
            Tracker
                .where(campaign_id: params[:campaign_id], id: params[:id])
                .first
                .json
        rescue => e
            status 404
            e.inspect
        end
    end

    post '/api/v1/campaigns/:campaign_id/trackers/?' do
        begin
            new_data = JSON.parse(request.body.read)
            campaign = Campaign.where(id: params[:campaign_id]).first
            saved_tracker = campaign.add_tracker(new_data)
        rescue => e
            logger.info "FAILED to create new tracker: #{e.inspect}"
            halt 400
        end

        status 201
        new_location = URI.join(@request_url.to_s + '/', saved_tracker.id.to_s).to_s
        headers('Location' => new_location)
    end
end
