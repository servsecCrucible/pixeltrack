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

  def url
    ENV['API_HOST'] + '/' + id + '.png'
  end

  def to_json(options = {})
    JSON({  type: 'tracker',
            id: id,
            attributes: {
              label: label,
              visits: visits,
              url: url
            }
          },
          options)
  end
end
