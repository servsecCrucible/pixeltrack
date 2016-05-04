# Find all campaign (owned and contributed to) by an account
class FindAccountAllCampaigns
  def self.call(account:)
    my_campaigns = Campaign.where(owner_id: account.id).all
    other_campaigns = Campaign.join(:accounts_campaigns, campaign_id: :id)
                              .where(contributor_id: account.id).all
    my_campaigns + other_campaigns
  end
end
