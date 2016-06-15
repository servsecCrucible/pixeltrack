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

  # def label=(label_plaintext)
  #   self.label_encrypted = encrypt(label_plaintext) if label_plaintext
  # end
  #
  # def label
  #   @label = decrypt(label_encrypted)
  # end

  def nb_visits
    trackers.map { |tracker| tracker.visits.size}.inject(0, :+)
  end

  def to_json(options = {})
    JSON({  type: 'campaign',
            id: id,
            attributes: {
              label: label,
              nb_visits: nb_visits
            }
          },
          options)
  end

end
