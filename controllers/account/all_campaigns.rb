# Sinatra Application Controllers
class PixelTrackerAPI < Sinatra::Base
  get '/api/v1/accounts/:username/campaigns/?' do
    content_type 'application/json'

    begin
      halt 401 unless authorized_account?(env, params[:username])
      username = params[:username]
      account = Account.where(username: username).first
      all_campaigns = FindAccountAllCampaigns.call(account: account)
      JSON.pretty_generate(data: all_campaigns)
    rescue => e
      logger.info "FAILED to get campaigns for #{username}: #{e}"
      halt 404
    end
  end
end
