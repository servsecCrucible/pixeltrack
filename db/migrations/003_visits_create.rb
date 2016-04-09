require 'sequel'

Sequel.migration do 
  change do
  	create_table(:visits) do
  	  primary_key :id
  	  foreign_key :tracker_id

  	  String :uid
  	  String :user_agent
  	  String :location
  	  String :date
  	  String :language
  	end
  end
end
