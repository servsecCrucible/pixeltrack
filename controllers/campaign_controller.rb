class PixelTrackerAPI < Sinatra::Base
  get '/api/v1/campaigns/:id/?' do
    content_type 'application/json'
    campaign_id = params[:id]
    campaign = affiliated_campaign(env, campaign_id)
    halt 401, 'Not authorized, or project might not exist' unless campaign
    JSON.pretty_generate(data: campaign, relationships: campaign.trackers)
  end

  get '/api/v1/campaigns/:id/trackers/?' do
    content_type 'application/json'
    campaign_id = params[:id]
    campaign = affiliated_campaign(env, campaign_id)
    halt 401, 'Not authorized, or project might not exist' unless campaign
    JSON.pretty_generate(data: campaign.trackers)
  end
end
