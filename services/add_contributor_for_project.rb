# Add a collaborator to another owner's existing project
class AddContributorForProject
  def self.call(contributor_id:, campaign_id:)
    contributor = BaseAccount[contributor_id.to_i]
    campaign = Campaign[campaign_id.to_i]
    if campaign.owner.id != contributor.id
      contributor.add_campaign(campaign)
      contributor
    else
      false
    end
  end
end
