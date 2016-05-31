# Sinatra Application Controllers
class PixelTrackerAPI < Sinatra::Base
  get '/api/v1/accounts/:username/?' do
    content_type 'application/json'

    username = params[:username]
    account = Account.where(username: username).first

    if account.is_a? Account
      campaigns = FindAllAccountCampaigns.call(id: account.id)
      JSON.pretty_generate(data: account, relationships: campaigns)
    else
      halt 404, "USER NOT FOUND: #{username}"
    end
  end

  post '/api/v1/accounts/?' do
    begin
      data = JSON.parse(request.body.read)
      new_account = CreateAccount.call(
        username: data['username'],
        email: data['email'],
        password: data['password'])
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
      username = params[:username]
      new_data = JSON.parse(request.body.read)

      account = Account.where(username: username).first
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
