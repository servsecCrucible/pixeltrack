require 'json'
require 'sequel'

# Holds the visits information for each pixel tracker
class Visit < Sequel::Model
  many_to_one :trackers
  set_allowed_columns nil

  def to_json(options = {})
    JSON({  type: 'tracker',
            id: id,
            data: {
              uid: uid,
              user_agent: user_agent,
              location: location,
              date: date,
              language: language
            }
          },
          options)
  end
end
