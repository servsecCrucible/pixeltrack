require 'json'
require 'sequel'

# Holds the visits information for each pixel tracker
class Campaign < Sequel::Model
  one_to_many :trackers

  def to_json(options = {})
  	JSON({ type: 'campaign',
  	       id: id,
  	       label: label,
  	  },
  		options)
  end

end
