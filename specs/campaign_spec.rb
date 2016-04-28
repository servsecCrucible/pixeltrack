require_relative './spec_helper'

describe 'Testing Campaign resource routes' do
  before do
    Tracker.dataset.destroy
    Campaign.dataset.destroy
    Account.dataset.destroy
    Visit.dataset.destroy
  end

  describe 'Creating new Campaigns' do
    it 'HAPPY: should create a new unique campaign' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { label: 'Demo Campaign' }.to_json
      post '/api/v1/campaigns/', req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'HAPPY: should encrypt relevant data' do
      original_label = "My best campaign"

      campaign = CreateNewCampaign.call(label: original_label)
      id = campaign.id

      _(Campaign[id].label).must_equal original_label
      _(Campaign[id].label_encrypted).wont_equal original_label
    end
  end

  describe 'Finding existing campaigns' do
    it 'HAPPY: should find an existing campaign' do
      new_campaign = CreateNewCampaign.call(label: 'Demo Campaign')
      new_trackers = (1..3).map do |i|
        new_campaign.add_tracker(label: "tracker_file#{i}")
      end

      get "/api/v1/campaigns/#{new_campaign.id}"
      _(last_response.status).must_equal 200

      results = JSON.parse(last_response.body)
      _(results['data']['id']).must_equal new_campaign.id
      3.times do |i|
        _(results['relationships'][i]['id']).must_equal new_trackers[i].id
      end
    end

    it 'SAD: should not find non-existent campaigns' do
      get "/api/v1/campaigns/#{invalid_id(Campaign)}"
      _(last_response.status).must_equal 404
    end
  end

  describe 'Getting an index of existing campaigns' do
    it 'HAPPY: should find list of existing campaigns' do
      (1..5).each { |i| CreateNewCampaign.call(label: "Campaign #{i}") }
      result = get '/api/v1/campaigns'
      camps = JSON.parse(result.body)
      _(camps['data'].count).must_equal 5
    end
  end
end
