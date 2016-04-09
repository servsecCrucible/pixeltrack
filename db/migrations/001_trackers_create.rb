require 'sequel'

Sequel.migration do 	
  change do
  	create_table(:trackers) do
  	  primary_key :id
  	  foreign_key :campaign_id
  	  
  	  String :label, null: false
  	  String :url, unique: true, null: false

  	  unique [:campaign_id, :label]
  	end
  end
end
