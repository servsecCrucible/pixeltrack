require 'json'
require 'sequel'

#Holds the trackers information
class Tracker < Sequel::Model
  include EncryptableModel
  plugin :uuid, :field => :id

  one_to_many :visits
  many_to_one :campaigns
  set_allowed_columns :label

  def label=(label_plaintext)
    self.label_encrypted = encrypt(label_plaintext)
  end

  def label
    @label = decrypt(label_encrypted)
  end

  def to_json(options = {})
    JSON({  type: 'tracker',
            id: id,
            attributes: {
              label: label,
              url: url
            }
          },
          options)
  end
end
