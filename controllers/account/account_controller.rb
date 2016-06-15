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
    content_type 'application/json'
    begin
      new_account = CreateAccount.call(request.body.read)
    rescue ClientNotAuthorized => e
      halt 401, e.to_s
    rescue => e
      logger.info "FAILED to create new account: #{e.inspect}"
      halt 400
    end

    status 201
    new_account.to_json
  end
end
