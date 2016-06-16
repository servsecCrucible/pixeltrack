class PixelTrackerAPI < Sinatra::Base
  get '/api/v1/campaigns/:id/?' do
    content_type 'application/json'

    campaign = affiliated_campaign(env, params[:id])
    halt 401, 'Not authorized, or campaign might not exist' unless campaign
    JSON.pretty_generate( data: campaign,
                          trackers: campaign.trackers,
                          contributors: campaign.contributors)
  end

  get '/api/v1/campaigns/:id/trackers/?' do
    content_type 'application/json'

    campaign = affiliated_campaign(env, params[:id])
    halt 401, 'Not authorized, or campaign might not exist' unless campaign
    JSON.pretty_generate(data: campaign.trackers)
  end

  post '/api/v1/campaigns/:id/contributors/?' do
    content_type 'application/json'
    begin
      criteria = JSON.parse request.body.read
      contributor = FindBaseAccountByEmail.call(criteria['email'])
      campaign = affiliated_campaign(env, params[:id])
      raise('Unauthorized or not found') unless campaign && contributor
      contributors = AddContributorForProject.call(
        contributor_id: contributor.id,
        campaign_id: campaign.id)
      contributors ? status(201) : raise('Could not add contributor')
    rescue => e
      logger.info "FAILED to add contributor to campaign: #{e.inspect}"
      halt 401
    end
    contributor.to_json
  end

  delete '/api/v1/campaigns/:campaign_id/?' do
    content_type 'application/json'
    begin
      campaign = affiliated_campaign(env, params[:campaign_id])
      halt 401, 'Not authorized, or campaign might not exist' unless campaign
      campaign.delete
    rescue => e
      logger.info "FAILED to remove campaign: #{e.inspect}"
      halt 400
    end
    status 200
  end
end
