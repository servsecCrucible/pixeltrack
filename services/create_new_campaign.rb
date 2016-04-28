# Service object to create new campaign using
class CreateNewCampaign
  def self.call(label:)
    campaign = Campaign.new(label: label)
    campaign.save
  end
end
