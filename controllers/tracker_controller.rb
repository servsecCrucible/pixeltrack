class PixelTrackerAPI < Sinatra::Base

  get '/:id.png' do
    RecordVisit.call(tracker: Tracker[params[:id]], environement: env)
    send_file 'public/image/pixel.png', :type => :jpg
  end

  get '/api/v1/campaigns/:campaign_id/trackers/:id/?' do
    content_type 'application/json'

    begin
        doc_url = URI.join(@request_url.to_s + '/', 'json')
        tracker = Tracker[params[:id]]
        halt(404, 'Tracker not found') unless tracker
        visits = tracker.visits
        JSON.pretty_generate(data: tracker, relationships: visits)
    rescue => e
        status 400
        logger.info "FAILED to process GET tracker request: #{e.inspect}"
        e.inspect
    end
  end

  post '/api/v1/campaigns/:campaign_id/trackers/?' do
    begin
        new_data = JSON.parse(request.body.read)
        campaign = Campaign[params[:campaign_id]]
        saved_tracker = campaign.add_tracker(new_data)
    rescue => e
        logger.info "FAILED to create new tracker: #{e.inspect}"
        halt 400
    end

    status 201
    new_location = URI.join(@request_url.to_s + '/', saved_tracker.id.to_s).to_s
    headers('Location' => new_location)
  end
end
