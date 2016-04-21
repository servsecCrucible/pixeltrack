require 'json'
require 'sequel'

# Holds the campaigns information for each pixel tracker
class Campaign < Sequel::Model
  include EncryptableModel

  one_to_many :trackers
  set_allowed_columns :label 

  def label=(label_plaintext)
    self.label_encrypted = encrypt(label_plaintext)
  end

  def label
    @label = decrypt(label_encrypted)
  end

  def to_json(options = {})
  	JSON({ type: 'campaign',
  	       id: id,
  	       label: label,
  	  },
  		options)
  end

end
