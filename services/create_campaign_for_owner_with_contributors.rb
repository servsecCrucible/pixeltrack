# Create new campaign for an owner with contributors
class CreateCampaignForOwnerWithContributors
  def self.call(owner:, label:, contributors:)
    saved_campaign = CreateCampaignForOwner.call(account: owner, label: label)
    contributors.each {|contributor| saved_campaign.add_contributor(contributor)}
    saved_campaign.save
  end
end
