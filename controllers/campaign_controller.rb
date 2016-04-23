class PixelTrackerAPI < Sinatra::Base
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
end
