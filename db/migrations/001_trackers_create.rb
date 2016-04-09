require 'sequel'

Sequel.migration do 	
  change do
  	create_table(:trackers) do
  	  primary_key :id
  	  foreign_key :campaign_id
  	  
  	  String :label, unique: true, null: false
  	  String :url, unique: true, null: false
  	end
  end
end