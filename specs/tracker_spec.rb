require_relative './spec_helper'

describe 'Testing Tracker resource routes' do
  before do
    Campaign.dataset.delete
    Tracker.dataset.delete
  end

  describe 'Creating new trackers for campaigns' do
    it 'HAPPY: should add a new tracker for an existing campaign' do
      existing_campaign = Campaign.create(label: 'Demo Campaign')

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

    it 'SAD: should catch duplicate tracker objects within a campaign' do
      existing_campaign = Campaign.create(label: 'Demo Campaign')

      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { label: 'Demo Tracker' }.to_json
      url = "/api/v1/campaigns/#{existing_campaign.id}/trackers"
      post url, req_body, req_header
      post url, req_body, req_header
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end
  end

  describe 'Getting trackers' do
    it 'HAPPY: should find existing tracker' do
      tracker = Campaign.create(label: 'Demo Campaign')
                        .add_tracker(label: 'demo_tracker')
      get "/api/v1/campaigns/#{tracker.campaign_id}/trackers/#{tracker.id}"
      _(last_response.status).must_equal 200
      parsed_tracker = JSON.parse(last_response.body)['data']['tracker']
      _(parsed_tracker['type']).must_equal 'tracker'
    end

    it 'SAD: should not find non-existant campaign and tracker' do
      camp_id = invalid_id(Campaign)
      track_id = invalid_id(Tracker)
      get "/api/v1/campaigns/#{camp_id}/trackers/#{track_id}"
      _(last_response.status).must_equal 404
    end

    it 'SAD: should not find non-existant tracker for existing campaign' do
      camp_id = Campaign.create(label: 'Demo Campaign').id
      track_id = invalid_id(Tracker)
      get "/api/v1/campaigns/#{camp_id}/trackers/#{track_id}"
      _(last_response.status).must_equal 404
    end
  end
end
