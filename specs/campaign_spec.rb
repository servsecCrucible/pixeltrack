require_relative 'spec_helper'

describe 'Testing Campaign resource routes' do
  before do
    Tracker.dataset.destroy
    Campaign.dataset.destroy
    BaseAccount.dataset.destroy
    Visit.dataset.destroy
  end

  describe 'create campaigns for accounts' do
    before do
      @account = CreateAccount.call(
        username: 'add.campaigns',
        email: 'add@campaign.dc',
        password: 'addcampaignpassword')
    end

    it 'HAPPY: should create a campaign for an account' do
      _, auth_token = AuthenticateAccount.call(
        username: @account.username, password: 'addcampaignpassword')
      req_header = {
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}",
        'CONTENT_TYPE' => 'application/json'
      }
      req_body = { label: 'Demo Campaign' }.to_json
      post "/api/v1/accounts/#{@account.username}/owned_campaigns",
        req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'Sad: should not create a campaign for an account with no auth_token' do
      req_header = {
        'CONTENT_TYPE' => 'application/json'
      }
      req_body = { label: 'Demo Campaign' }.to_json
      post "/api/v1/accounts/#{@account.username}/owned_campaigns",
        req_body, req_header
      _(last_response.status).must_equal 401
    end
  end


  describe 'Finding existing campaigns' do
    before do
      @account = CreateAccount.call(
        username: 'find.campaigns',
        email: 'find@campaign.dc',
        password: 'findcampaignpassword')
      @campaign = CreateCampaignForOwner.call(
        account: @account, label: 'Demo Campaign')
      @trackers = (1..3).map do |i|
        @campaign.add_tracker(label: "tracker_file#{i}")
      end
    end

    it 'HAPPY: should find an existing campaign' do
      _, auth_token = AuthenticateAccount.call(
        username: 'find.campaigns', password: 'findcampaignpassword')
      get "/api/v1/campaigns/#{@campaign.id}", nil,
        { "HTTP_AUTHORIZATION" => "Bearer #{auth_token}" }
      _(last_response.status).must_equal 200

      results = JSON.parse(last_response.body)
      _(results['data']['id']).must_equal @campaign.id
      3.times do |i|
        _(results['relationships'][i]['id']).must_equal @trackers[i].id
      end
    end

    it 'SAD: should not find non-existent campaigns' do
      get "/api/v1/campaigns/#{invalid_id(Campaign)}"
      _(last_response.status).must_equal 401
    end
  end
end
