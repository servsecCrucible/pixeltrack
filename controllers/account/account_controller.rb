# Sinatra Application Controllers
class PixelTrackerAPI < Sinatra::Base
  get '/api/v1/accounts/:username/?' do
    content_type 'application/json'
    halt 401 unless authorized_account?(env, params[:username])
    account = authenticated_account(env)
    if account
      campaigns = FindAllAccountCampaigns.call(id: account['id'])
      JSON.pretty_generate(data: account, relationships: campaigns)
    else
      halt 404, "ACCOUNT NOT FOUND: #{username}"
    end
  end

  post '/api/v1/accounts/?' do
    begin
      new_account = CreateAccount.call(request.body.read)
    rescue ClientNotAuthorized => e
      halt 401, e.to_s
    rescue => e
      logger.info "FAILED to create new account: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', new_account.username).to_s

    status 201
    headers('Location' => new_location)
  end

  post '/api/v1/accounts/:username/campaigns/?' do
    begin
      halt 401 unless authorized_account?(env, params[:username])
      account = authenticated_account(env)
      new_data = JSON.parse(request.body.read)

      account = Account[account['id']]
      saved_campaign = CreateCampaignForOwner.call( account: account,
                                                    label: new_data['label'])
    rescue => e
      logger.info "FAILED to create new campaign: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', saved_campaign.id.to_s).to_s

    status 201
    headers('Location' => new_location)
  end
end
