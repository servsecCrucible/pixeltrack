require 'json'
require 'sequel'

# Holds the visits information for each pixel tracker
class Visit < Sequel::Model
  many_to_one :trackers
  set_allowed_columns :date

  def to_json(options = {})
    JSON({  type: 'tracker',
            id: id,
            data: {
              platform: platform,
              os: os,
              date: date,
              language: language,
              ip: ip,
              isMobile: isMobile,
              isBot: isBot
            }
          },
          options)
  end
end
