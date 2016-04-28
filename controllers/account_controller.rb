# Sinatra Application Controllers
class ShareConfigurationsAPI < Sinatra::Base
  get '/api/v1/accounts/:username' do
    content_type 'application/json'

    username = params[:username]
    account = Account.where(username: username).first

    if account
      campaigns = account.owned_campaigns
      JSON.pretty_generate(data: account, relationships: campaigns)
    else
      halt 404, "CAMPAIGN NOT FOUND: #{username}"
    end
  end

  post '/api/v1/accounts/?' do
    begin
      data = JSON.parse(request.body.read)
      new_account = CreateNewAccount.call(
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
      saved_campaign = account.add_owned_campaign(name: new_data['name'])
      saved_campaign.save
    rescue => e
      logger.info "FAILED to create new campaign: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', saved_campaign.id.to_s).to_s

    status 201
    headers('Location' => new_location)
  end

  get '/api/v1/accounts/:username/campaigns/?' do
    content_type 'application/json'

    begin
      username = params[:username]
      account = Account.where(username: username).first

      my_campaigns = Campaign.where(owner_id: account.id).all
      other_campaigns = Campaign.join(:accounts_campaigns, campaign_id: :id)
                              .where(contributor_id: account.id).all

      all_campaigns = my_campaigns + other_campaigns
      JSON.pretty_generate(data: all_campaigns)
    rescue => e
      logger.info "FAILED to get campaigns for #{username}: #{e}"
      halt 404
    end
  end
end
