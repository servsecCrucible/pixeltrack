# Find all campaign (owned and contributed to) by an account
class FindAllAccountCampaigns
  def self.call(id:)
    base_account = BaseAccount[id]
    my_campaigns = base_account.owned_campaigns
    other_campaigns = base_account.campaigns
    my_campaigns + other_campaigns
  end
end
