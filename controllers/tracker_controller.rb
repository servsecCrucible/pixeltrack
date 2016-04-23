class PixelTrackerAPI < Sinatra::Base
  get '/api/v1/campaigns/:campaign_id/trackers/:id/?' do
    content_type 'application/json'

    begin
        doc_url = URI.join(@request_url.to_s + '/', 'json')
        tracker = Tracker
                  .where(campaign_id: params[:campaign_id], id: params[:id])
                  .first
        halt(404, 'Tracker not found') unless tracker
        JSON.pretty_generate(data: {
                                 tracker: tracker,
                                 links: { item_url: doc_url }
                             })
    rescue => e
        status 400
        logger.info "FAILED to process GET tracker request: #{e.inspect}"
        e.inspect
    end
  end

  post '/api/v1/campaigns/:campaign_id/trackers/?' do
    begin
        new_data = JSON.parse(request.body.read)
        campaign = Campaign.where(id: params[:campaign_id]).first
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
