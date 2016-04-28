require 'json'
require 'sequel'

# Holds the campaigns information for each pixel tracker
class Campaign < Sequel::Model
  include SecureModel

  set_allowed_columns :label

  one_to_many :trackers
  many_to_one :owner, class: :Account
  many_to_many :contributors,
               class: :Account, join_table: :accounts_campaigns,
               left_key: :campaign_id, right_key: :contributor_id

  plugin :association_dependencies, trackers: :destroy

  def before_destroy
    DB[:accounts_campaigns].where(campaign_id: id).delete
    super
  end

  # def label=(label_plaintext)
  #   self.label_encrypted = encrypt(label_plaintext) if label_plaintext
  # end
  #
  # def label
  #   @label = decrypt(label_encrypted)
  # end

  def to_json(options = {})
  	JSON({ type: 'campaign',
  	       id: id,
  	       label: label,
  	  },
  		options)
  end

end
