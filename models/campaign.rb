require 'json'
require 'sequel'

# Holds the campaigns information for each pixel tracker
class Campaign < Sequel::Model
  set_allowed_columns :label

  one_to_many :trackers
  many_to_one :owner, class: :BaseAccount
  many_to_many :contributors,
               class: :BaseAccount, join_table: :base_accounts_campaigns,
               left_key: :campaign_id, right_key: :contributor_id

  plugin :association_dependencies, trackers: :destroy

  def before_destroy
    DB[:base_accounts_campaigns].where(campaign_id: id).delete
    super
  end

  def nb_visits
    trackers.map { |tracker| tracker.visits.size}.inject(0, :+)
  end

  def to_json(options = {})
    JSON({  type: 'campaign',
            id: id,
            attributes: {
              label: label,
              owner: owner,
              nb_visits: nb_visits
            }
          },
          options)
  end

end
