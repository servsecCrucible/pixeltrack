# Sinatra Application Controllers
class PixelTrackerAPI < Sinatra::Base
  post '/api/v1/accounts/authenticate' do
    content_type 'application/json'

    credentials = JSON.parse(request.body.read)
    account, auth_token = FindAndAuthenticateAccount.call(
      username: credentials['username'], password: credentials['password'])
    
    if account
      { account: account, 
        auth_token: auth_token}.to_json
    else
      halt 401, "Account #{username} could not be authenticated"
    end
  end
end
