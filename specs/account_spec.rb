require_relative 'spec_helper'

describe 'Testing Account resource routes' do
  before do
    Tracker.dataset.destroy
    Campaign.dataset.destroy
    BaseAccount.dataset.destroy
    Visit.dataset.destroy
  end

  describe 'Creating new account' do
    before do
      @registration = {
        'username' => 'test.name',
        'password' => 'mypass',
        'email' => 'test@email.com' }
      @req_body = client_signed(@registration)
    end

    it 'HAPPY: should create a new unique account' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/accounts/', @req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not create accounts with duplicate usernames' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      registration_duplicate = {
        'username' => 'test.name',
        'password' => 'mypassword',
        'email' => 'testduplicate@email.com' }
      req_body = client_signed(registration_duplicate)
      post '/api/v1/accounts/', req_body, req_header
      post '/api/v1/accounts/', req_body, req_header
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end

    it 'BAD: should not create account unless requested from authorized app' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body_not_signed = @registration.to_json
      post '/api/v1/accounts/', req_body_not_signed, req_header
      _(last_response.status).must_equal 401
      _(last_response.location).must_be_nil
    end
  end

  describe 'Testing unit level properties of accounts' do
    before do
      @original_password = 'supermansucks'
      @account = create_client_account({
        'username' => 'bat.man',
        'email' => 'batman@batcave.gotham.dc',
        'password' => @original_password})
    end

    it 'HAPPY: should hash the password' do
      _(@account.password_hash).wont_equal @original_password
    end

    it 'HAPPY: should re-salt the password' do
      hashed = @account.password_hash
      @account.password = @original_password
      @account.save
      _(@account.password_hash).wont_equal hashed
    end
  end

  describe 'Finding an existing account' do
    it 'HAPPY: should find an existing account' do
      new_account = create_client_account({
        'username' => 'test.name',
        'email' => 'test@email.com',
        'password' => 'mypassword'})
      new_campaigns = (1..3).map do |i|
        new_account.add_owned_campaign(label: "Campaign #{i}")
      end
      auth_token = authorized_account_token({
        'username' => 'test.name', 'password' => 'mypassword'})

      get "/api/v1/accounts/#{new_account.username}", nil,
        { "HTTP_AUTHORIZATION" => "Bearer #{auth_token}" }
      _(last_response.status).must_equal 200

      results = JSON.parse(last_response.body)
      _(results['data']['username']).must_equal new_account.username
      3.times do |i|
        _(results['relationships'][i]['id']).must_equal new_campaigns[i].id
      end
    end

    it 'SAD: should not find non-existent accounts' do
      get "/api/v1/accounts/I-DO-NOT-EXIST"
      _(last_response.status).must_equal 401
    end
  end

  describe 'Creating new campaign for account owner' do
    before do
      @account = create_client_account({
        'username' => 'soumya.ray',
        'email' => 'sray@nthu.edu.tw',
        'password' => 'mypassword'})
      @auth_token = authorized_account_token({
        'username' => 'soumya.ray', 'password' => 'mypassword'})
    end

    it 'HAPPY: should create a new unique campaign for account' do
      req_header = {
        'CONTENT_TYPE' => 'application/json',
        "HTTP_AUTHORIZATION" => "Bearer #{@auth_token}" }
      req_body = { label: 'Demo Campaign' }.to_json
      post "/api/v1/accounts/#{@account.username}/campaigns/",
           req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not create campaigns with duplicate names' do
      req_header = {
        'CONTENT_TYPE' => 'application/json',
        "HTTP_AUTHORIZATION" => "Bearer #{@auth_token}" }
      req_body = { name: 'Demo Campaign' }.to_json
      2.times do
        post "/api/v1/accounts/#{@account.username}/campaigns/",
             req_body, req_header
      end
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end

    it 'HAPPY: should encrypt relevant data' do
      original_url = 'http://example.org/campaign/test.git'

      camp = @account.add_owned_campaign(label: 'Secret Label')
      camp.save

      original_label = 'Secret label'
      track = camp.add_tracker(label: original_url)
      track.label = original_label
      track.save

      _(Tracker[track.id].label).must_equal original_label
      _(Tracker[track.id].label_encrypted).wont_equal original_label
    end
  end

  describe 'Authenticating an account' do
    # TODO: only allow authorized client apps (to prevent brute force checks)
    def login_with(username:, password:)
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = client_signed({'username' => username, 'password' => password})
      post '/api/v1/accounts/authenticate', req_body, req_header
    end

    before do
      @account = create_client_account({
        'username' => 'soumya.ray',
        'email' => 'sray@nthu.edu.tw',
        'password' => 'soumya.password'})
    end

    it 'HAPPY: should be able to authenticate a real account' do
      login_with(username: 'soumya.ray', password: 'soumya.password')
      _(last_response.status).must_equal 200
      response = JSON.parse(last_response.body)
      _(response['account']).wont_equal nil
      _(response['auth_token']).wont_equal nil
    end

    it 'SAD: should not authenticate an account with wrong password' do
      login_with(username: 'soumya.ray', password: 'guess.password')
      _(last_response.status).must_equal 401
    end

    it 'SAD: should not authenticate an account with an invalid username' do
      login_with(username: 'randomuser', password: 'soumya.password')
      _(last_response.status).must_equal 401
    end

    it 'BAD: should not authenticate an account without app signature' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = {'username' => 'soumya.ray', 'password' => 'soumya.password'}.to_json
      post '/api/v1/accounts/authenticate', req_body, req_header
      _(last_response.status).must_equal 401
    end

    it 'BAD: should not authenticate an account without password' do
      login_with(username: 'soumya.ray', password: '')
      _(last_response.status).must_equal 401
    end
  end

  describe 'Get index of all campaign for an account' do
    it 'HAPPY: should find all campaigns for an account' do
      my_account = create_client_account({
        'username' => 'super.man',
        'email' => 'sman@nthu.edu.tw',
        'password' => 'mypassword'})

      other_account = create_client_account({
        'username' => 'wonderwoman',
        'email' => 'wonder@nthu.edu.tw',
        'password' => 'wonderpassword'})

      my_camps = []
      3.times do |i|
        my_camps << my_account.add_owned_campaign(
          label: "Campaign #{my_account.id}-#{i}")
        other_account.add_owned_campaign(
          label: "Campaign #{other_account.id}-#{i}")
      end

      other_account.owned_campaigns.each.with_index do |camp, i|
        my_camps << my_account.add_campaign(camp) if i < 2
      end

      auth_token = authorized_account_token({
        'username' => 'super.man', 'password' => 'mypassword'})

      result = get "/api/v1/accounts/#{my_account.username}/campaigns", nil,
        { "HTTP_AUTHORIZATION" => "Bearer #{auth_token}" }

      _(result.status).must_equal 200
      camps = JSON.parse(result.body)

      valid_ids = my_camps.map(&:id)
      _(camps['data'].count).must_equal 5
      camps['data'].each do |camp|
        _(valid_ids).must_include camp['id']
      end
    end
  end
end
