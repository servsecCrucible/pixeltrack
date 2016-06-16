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
      @account = create_client_account({
        'username' => 'add.campaigns',
        'email' => 'add@campaign.dc',
        'password' => 'addcampaignpassword'})
    end

    it 'HAPPY: should create a campaign for an account' do
      auth_token = authorized_account_token({
        'username' => @account.username, 'password' => 'addcampaignpassword'})
      req_header = {
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}",
        'CONTENT_TYPE' => 'application/json'
      }
      req_body = { label: 'Demo Campaign' }.to_json
      post "/api/v1/accounts/#{@account.username}/owned_campaigns",
        req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.body).wont_be_empty
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
      @account = create_client_account({
        'username' => 'find.campaigns',
        'email' => 'find@campaign.dc',
        'password' => 'findcampaignpassword'})
      @campaign = CreateCampaignForOwner.call(
        account: @account, label: 'Demo Campaign')
      @trackers = (1..3).map do |i|
        @campaign.add_tracker(label: "tracker_file#{i}")
      end
      @contributor = create_client_account({
        'username' => 'contributor',
        'email' => 'contributor@campaign.dc',
        'password' => 'contributorpassword'})
      @campaign.add_contributor(@contributor)
      @auth_token = authorized_account_token({
        'username' => 'find.campaigns', 'password' => 'findcampaignpassword'})
    end

    it 'HAPPY: should find an existing campaign trackers and collaborator' do
      get "/api/v1/campaigns/#{@campaign.id}", nil,
        { "HTTP_AUTHORIZATION" => "Bearer #{@auth_token}" }
      _(last_response.status).must_equal 200
      results = JSON.parse(last_response.body)
      _(results['data']['id']).must_equal @campaign.id
    end

    it 'HAPPY: should find an existing campaign trackers' do
      get "/api/v1/campaigns/#{@campaign.id}", nil,
        { "HTTP_AUTHORIZATION" => "Bearer #{@auth_token}" }
      _(last_response.status).must_equal 200
      results = JSON.parse(last_response.body)
      3.times do |i|
        _(results['trackers'][i]['id']).must_equal @trackers[i].id
      end
    end

    it 'HAPPY: should find an existing campaign contributor' do
      get "/api/v1/campaigns/#{@campaign.id}", nil,
        { "HTTP_AUTHORIZATION" => "Bearer #{@auth_token}" }
      _(last_response.status).must_equal 200
      results = JSON.parse(last_response.body)
      _(results['contributors'][0]['id']).must_equal @contributor.id
    end

    it 'SAD: should not find non-existent campaigns' do
      get "/api/v1/campaigns/#{invalid_id(Campaign)}"
      _(last_response.status).must_equal 401
    end
  end

  describe 'Add a contributor to a campaign' do
    before do
      @owner = create_client_account(
        username: 'owner_contrib', email: 'owner@contrib.edu.tw', password: 'owner_contrib_pass')
      @contributor = create_client_account(
        username: 'contributorToAdd', email: 'contributorToAdd@nthu.edu.tw', password: 'contributorToAddpassword')
      @campaign = @owner.add_owned_campaign(label: 'Collaborator Needed')
      @auth_token = authorized_account_token(
        username: 'owner_contrib', password: 'owner_contrib_pass')
      @req_header = { 'CONTENT_TYPE' => 'application/json',
                      'HTTP_AUTHORIZATION' => "Bearer #{@auth_token}" }
    end

    it 'HAPPY: should add a collaborative campaign' do
      result = post "/api/v1/campaigns/#{@campaign.id}/contributors",
                    { email: @contributor.email }.to_json, @req_header
      _(result.status).must_equal 201
      _(@contributor.campaigns.map(&:id)).must_include @campaign.id
    end

    it 'SAD: should not be able to add non-existent contributor' do
      result = post "/api/v1/campaigns/#{@campaign.id}/contributors",
                    { email: 'unknown@mail.com' }.to_json, @req_header
      _(result.status).must_equal 401
    end

    it 'BAD: should not be able to add campaign owner as contributor' do
      result = post "/api/v1/campaigns/#{@campaign.id}/contributors",
                    { email: @owner.email }.to_json, @req_header
      _(result.status).must_equal 401
      _(@owner.campaigns.map(&:id)).wont_include @campaign.id
    end
  end

  describe 'Deleting campaign' do
    before do
      @account = create_client_account({
        'username' => 'delete.campaign',
        'email' => 'delete@campaign.dc',
        'password' => 'deletecampaignpassword'})
      @campaignToDelete = CreateCampaignForOwner.call(
        account: @account, label: 'Campaign to delete')
      @campaignToNotDelete = CreateCampaignForOwner.call(
        account: @account, label: 'Campaign to not delete')
      @auth_token = authorized_account_token({
        'username' => @account.username, 'password' => 'deletecampaignpassword'})
    end

    it 'HAPPY: should delete a campaign' do
      req_header = {
        'HTTP_AUTHORIZATION' => "Bearer #{@auth_token}",
        'CONTENT_TYPE' => 'application/json'
      }
      delete "/api/v1/campaigns/#{@campaignToDelete.id}",
        _, req_header
      _(last_response.status).must_equal 200
      Campaign[@campaignToDelete.id].must_be_nil
    end

    it 'SAD: should not delete a campaign with no auth_token' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      delete "/api/v1/campaigns/#{@campaignToNotDelete.id}",
        _, req_header
      _(last_response.status).must_equal 401
      Campaign[@campaignToNotDelete.id].id.must_equal @campaignToNotDelete.id
    end
  end
end
