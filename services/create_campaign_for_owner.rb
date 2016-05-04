# Create new campaign for an owner
class CreateCampaignForOwner
  def self.call(account:, label:)
    saved_campaign = account.add_owned_campaign(label: label)
    saved_campaign.save
  end
end
