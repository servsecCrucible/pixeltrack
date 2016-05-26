# Create new tracker for a campaign
class CreateTrackerForCampaign
  def self.call(campaign:, label:)
    saved_tracker = campaign.add_tracker(label: label)
    saved_tracker.save
  end
end
