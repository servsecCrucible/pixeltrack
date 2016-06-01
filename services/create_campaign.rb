# Service object to create new campaign using
class CreateCampaign
  def self.call(label:)
    campaign = Campaign.new(label: label)
    campaign.save
  end
end
