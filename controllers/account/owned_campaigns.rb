# Sinatra Application Controllers
class PixelTrackerAPI < Sinatra::Base
  post '/api/v1/accounts/:username/owned_campaigns/?' do
    content_type 'application/json'
    begin
      halt 401 unless authorized_account?(env, params[:username])
      account = authenticated_account(env)
      new_data = JSON.parse(request.body.read)
      saved_campaign = CreateCampaignForOwner.call(
        account: Account[account['id']], label: new_data['label'])
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
      owned_campaigns = Account[account['id']].campaigns
      JSON.pretty_generate(data: owned_campaigns)
    rescue => e
      logger.info "FAILED to get campaigns for #{username}: #{e}"
      halt 404
    end
  end
end
