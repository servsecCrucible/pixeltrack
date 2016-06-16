# Service object to delete new campaign using
class DeleteCampaign
  def self.call(campaign:)
    campaign.remove_all_contributors
    campaign.delete
  end
end
