class PixelTrackerAPI < Sinatra::Base
  get '/:id.png' do
    RecordVisit.call(tracker: Tracker[params[:id]], environement: env)
    send_file 'public/image/pixel.png', :type => :jpg
  end

  get '/api/v1/campaigns/:campaign_id/trackers/:id/?' do
    content_type 'application/json'

    begin
      campaign = affiliated_campaign(env, params[:campaign_id])
      halt 401, 'Not authorized, or tracker might not exist' unless campaign
      tracker = Tracker
        .where(campaign_id: params[:campaign_id], id: params[:id])
        .first
      halt 401, 'Not authorized, or tracker might not exist' unless tracker
      visits = tracker.visits
      JSON.pretty_generate(data: tracker, relationships: visits)
    rescue => e
        status 400
        logger.info "FAILED to process GET tracker request: #{e.inspect}"
        e.inspect
    end
  end

  post '/api/v1/campaigns/:campaign_id/trackers/?' do
    content_type 'application/json'
    begin
        campaign = affiliated_campaign(env, params[:campaign_id])
        halt 401, 'Not authorized, or tracker might not exist' unless campaign
        new_data = JSON.parse(request.body.read)
        saved_tracker = campaign.add_tracker(new_data)
    rescue => e
        logger.info "FAILED to create new tracker: #{e.inspect}"
        halt 400
    end

    status 201
    saved_tracker.to_json
  end
end
