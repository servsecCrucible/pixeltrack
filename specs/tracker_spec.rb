require_relative 'spec_helper'

describe 'Testing Tracker resource routes' do
  before do
    Tracker.dataset.destroy
    Campaign.dataset.destroy
    BaseAccount.dataset.destroy
    Visit.dataset.destroy
  end

  describe 'Creating new trackers for campaigns' do
    before do
      @account = create_client_account({
        'username' => 'add.tracker',
        'email' => 'add@tracker.dc',
        'password' => 'addtrackerpassword'})
      @existing_campaign = CreateCampaignForOwner.call(
        account: @account, label: 'Demo Campaign')
      @auth_token = authorized_account_token({
        'username' => @account.username, 'password' => 'addtrackerpassword'})
    end

    it 'HAPPY: should add a new tracker for an existing campaign' do
      req_header = {
        'HTTP_AUTHORIZATION' => "Bearer #{@auth_token}",
        'CONTENT_TYPE' => 'application/json'
      }
      req_body = { label: 'Demo Tracker' }.to_json
      post "/api/v1/campaigns/#{@existing_campaign.id}/trackers",
           req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.body).wont_be_empty
    end

    it 'SAD: should not add a tracker for non-existant campaign' do
      req_header = {
        'HTTP_AUTHORIZATION' => "Bearer #{@auth_token}",
        'CONTENT_TYPE' => 'application/json'
      }
      req_body = { label: 'Demo Tracker' }.to_json
      post "/api/v1/campaigns/#{invalid_id(Campaign)}/trackers",
           req_body, req_header
      _(last_response.status).must_equal 401
      _(last_response.location).must_be_nil
    end

    it 'SAD: should not add a tracker with no auth_token' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { label: 'Demo Tracker' }.to_json
      post "/api/v1/campaigns/#{@existing_campaign.id}/trackers",
           req_body, req_header
      _(last_response.status).must_equal 401
      _(last_response.location).must_be_nil
    end
  end

  describe 'Getting trackers' do
    it 'HAPPY: should find existing tracker' do
      account = create_client_account({
        'username' => 'find.tracker',
        'email' => 'find@tracker.dc',
        'password' => 'findtrackerpassword'})
      tracker = CreateCampaignForOwner
        .call(account: account, label: 'Demo Campaign')
        .add_tracker(label: 'demo_tracker')
      auth_token = authorized_account_token({
        'username' => account.username, 'password' => 'findtrackerpassword'})
      get "/api/v1/campaigns/#{tracker.campaign_id}/trackers/#{tracker.id}",
        nil, {'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"}
      _(last_response.status).must_equal 200
      parsed_tracker = JSON.parse(last_response.body)['data']
      _(parsed_tracker['type']).must_equal 'tracker'
    end

    it 'HAPPY: should encrypt relevant data' do
      original_label = "Super pixel tracker"

      tracker = CreateTracker.call(label: original_label)
      id = tracker.id

      _(Tracker[id].label).must_equal original_label
      _(Tracker[id].label_encrypted).wont_equal original_label
    end

    it 'SAD: should not find non-existant campaign and tracker' do
      camp_id = invalid_id(Campaign)
      track_id = invalid_id(Tracker)
      get "/api/v1/campaigns/#{camp_id}/trackers/#{track_id}"
      _(last_response.status).must_equal 401
    end

    it 'SAD: should not find non-existant tracker for existing campaign' do
      camp_id = CreateCampaign.call(label: 'Demo Campaign').id
      track_id = invalid_id(Tracker)
      get "/api/v1/campaigns/#{camp_id}/trackers/#{track_id}"
      _(last_response.status).must_equal 401
    end
  end

  describe 'Deleting tracker' do
    before do
      @account = create_client_account({
        'username' => 'delete.tracker',
        'email' => 'delete@tracker.dc',
        'password' => 'deletetrackerpassword'})
      @campaign = CreateCampaignForOwner.call(
        account: @account, label: 'Demo Campaign')
      @auth_token = authorized_account_token({
        'username' => @account.username, 'password' => 'deletetrackerpassword'})
      @trackerToDel = @campaign.add_tracker(label: "tracker to delete")
      @trackerToNotDel = @campaign.add_tracker(label: "tracker to not delete")
    end

    it 'HAPPY: should delete a tracker' do
      req_header = {
        'HTTP_AUTHORIZATION' => "Bearer #{@auth_token}",
        'CONTENT_TYPE' => 'application/json'
      }
      delete "/api/v1/campaigns/#{@campaign.id}/trackers/#{@trackerToDel.id}",
        _, req_header
      _(last_response.status).must_equal 200
      Tracker[@trackerToDel.id].must_be_nil
    end

    it 'SAD: should not delete a tracker for non-existant tracker' do
      req_header = {
        'HTTP_AUTHORIZATION' => "Bearer #{@auth_token}",
        'CONTENT_TYPE' => 'application/json'
      }
      delete "/api/v1/campaigns/#{invalid_id(Campaign)}/trackers/0e309683-a89e-4a63-a582-f11dd80311ab",
           _, req_header
      _(last_response.status).must_equal 401
      _(last_response.location).must_be_nil
    end

    it 'SAD: should not add a tracker with no auth_token' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      delete "/api/v1/campaigns/#{@campaign.id}/trackers/#{@trackerToNotDel.id}",
        _, req_header
      _(last_response.status).must_equal 401
      Tracker[@trackerToNotDel.id].id.must_equal @trackerToNotDel.id
    end
  end
end
