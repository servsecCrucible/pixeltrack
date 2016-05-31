require_relative './spec_helper'

describe 'Testing Tracker resource routes' do
  before do
    Tracker.dataset.destroy
    Campaign.dataset.destroy
    Account.dataset.destroy
    Visit.dataset.destroy
  end

  describe 'Creating new trackers for campaigns' do
    it 'HAPPY: should add a new tracker for an existing campaign' do
      existing_campaign = CreateCampaign.call(label: 'Demo Campaign')

      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { label: 'Demo Tracker' }.to_json
      post "/api/v1/campaigns/#{existing_campaign.id}/trackers",
           req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not add a tracker for non-existant campaign' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { label: 'Demo Tracker' }.to_json
      post "/api/v1/campaigns/#{invalid_id(Campaign)}/trackers",
           req_body, req_header
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end
  end

  describe 'Getting trackers' do
    it 'HAPPY: should find existing tracker' do
      tracker = CreateCampaign.call(label: 'Demo Campaign').add_tracker(label: 'demo_tracker')
      get "/api/v1/campaigns/#{tracker.campaign_id}/trackers/#{tracker.id}"
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
      _(last_response.status).must_equal 404
    end

    it 'SAD: should not find non-existant tracker for existing campaign' do
      camp_id = CreateCampaign.call(label: 'Demo Campaign').id
      track_id = invalid_id(Tracker)
      get "/api/v1/campaigns/#{camp_id}/trackers/#{track_id}"
      _(last_response.status).must_equal 404
    end
  end
end
