require 'json'
require 'sequel'

#Holds the trackers information
class Tracker < Sequel::Model
  plugin :uuid, :field => :id

  one_to_many :visits
  many_to_one :campaigns
  set_allowed_columns :label

  plugin :association_dependencies, visits: :destroy

  def label=(label_plaintext)
    self.label_encrypted = SecureDB.encrypt(label_plaintext) if label_plaintext
  end

  def label
    SecureDB.decrypt(label_encrypted)
  end

  def to_json(options = {})
    JSON({  type: 'tracker',
            id: id,
            attributes: {
              label: label,
              url: url,
              visits: visits
            }
          },
          options)
  end

  def to_json_lite(options = {})
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
