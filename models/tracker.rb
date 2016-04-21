require 'json'
require 'sequel'

#Holds the trackers information
class Tracker < Sequel::Model
  one_to_many :visits
  many_to_one :campaigns
  set_allowed_columns :label  

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

