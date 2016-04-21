require 'json'
require 'sequel'

# Holds the campaigns information for each pixel tracker
class Campaign < Sequel::Model
  one_to_many :trackers
  set_allowed_columns :label 

  def to_json(options = {})
  	JSON({ type: 'campaign',
  	       id: id,
  	       label: label,
  	  },
  		options)
  end

end
