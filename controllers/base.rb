require 'sinatra'
require 'json'
require 'rack/ssl-enforcer'

# Configuration of Pixel tracker API
class PixelTrackerAPI < Sinatra::Base

  configure :production do
    use Rack::SslEnforcer
  end

  def authenticated_account(env)
    scheme, auth_token = env['HTTP_AUTHORIZATION'].split(' ')
    account_payload = JSON.load SecureClientMessage.decrypt(auth_token)
    (scheme =~ /^Bearer$/i) ? account_payload : nil
  end

  def authorized_account?(env, username)
    account = authenticated_account(env)
    account['username'] == username
  rescue
    false
  end

  def affiliated_campaign(env, campaign_id)
    account = authenticated_account(env)
    all_campaigns = FindAllAccountCampaigns.call(id: account['id'])
    all_campaigns.select { |camp| camp.id == campaign_id.to_i }.first
  rescue
    nil
  end

  def affiliated_owned_campaign(env, campaign_id)
    account = authenticated_account(env)
    owned_campaigns = BaseAccount[account['id']].owned_campaigns
    owned_campaigns.select { |camp| camp.id == campaign_id.to_i }.first
  rescue
    nil
  end

  before do
    host_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    @request_url = URI.join(host_url, request.path.to_s)
  end

  get '/?' do
    'Welcome to Servesec Crucible Pixeltrack service'
  end

  get '/api/v1/?' do
    content_type 'application/json'
    apidoc = {
      '/api/v1/' => {
        'get' => {
          'parameters' => 'None',
          'status' => '200',
          'data' => 'help'
        }
      },
      '/api/v1/pixels/' => {
        'get' => {
          'parameters' => 'None',
          'status' => '200',
          'data' => 'return the list of pixel ids'
        },
        'post' => {
          'parameters' => {
            'id' => 'id of the new pixel (optional)',
            'label' => 'label of the pixel'
          },
          'status' => '300',
          'data' => 'redirect to the new created pixel'
        }
      },
      '/api/v1/pixels/:id.json' => {
        'get' => {
          'parameters' => 'None',
          'status' => '200',
          'data' => 'pixel details'
        }
      }
    }
    apidoc.to_json
  end
end
