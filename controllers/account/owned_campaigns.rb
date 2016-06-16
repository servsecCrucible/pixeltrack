# Sinatra Application Controllers
class PixelTrackerAPI < Sinatra::Base
  post '/api/v1/accounts/:username/owned_campaigns/?' do
    content_type 'application/json'
    begin
      halt 401 unless authorized_account?(env, params[:username])
      account = authenticated_account(env)
      new_data = JSON.parse(request.body.read)
      saved_campaign = CreateCampaignForOwner.call(
        account: BaseAccount[account['id']], label: new_data['label'])
    rescue => e
      logger.info "FAILED to create new campaign: #{e.inspect}"
      halt 400
    end
    status 201
    saved_campaign.to_json
  end

  get '/api/v1/accounts/:username/owned_campaigns/?' do
    content_type 'application/json'

    begin
      halt 401 unless authorized_account?(env, params[:username])
      account = authenticated_account(env)
      owned_campaigns = BaseAccount[account['id']].campaigns
      JSON.pretty_generate(data: owned_campaigns)
    rescue => e
      logger.info "FAILED to get campaigns for #{username}: #{e}"
      halt 404
    end
  end

  delete '/api/v1/accounts/:username/owned_campaigns/:campaign_id/?' do
    content_type 'application/json'
    begin
      halt 401 unless authorized_account?(env, params[:username])
      campaign =  affiliated_owned_campaign(env, params[:campaign_id])
      halt 401, 'Not authorized, or campaign might not exist' unless campaign
      DeleteCampaign.call(campaign: campaign)
    rescue => e
      puts "FAILED to remove campaign: #{e.inspect}"
      halt 400
    end
    status 200
  end
end
