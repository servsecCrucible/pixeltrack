# Find all campaign (owned and contributed to) by an account
class FindAccountAllCampaigns
  def self.call(account:)
    my_campaigns = account.owned_campaigns
    other_campaigns = account.campaigns
    my_campaigns + other_campaigns
  end
end
