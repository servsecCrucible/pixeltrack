require 'sequel'

Sequel.migration do
  change do
    create_table(:visits) do
      primary_key :id
      foreign_key :tracker_id

      String :platform
      String :os
      String :date
      String :language
      String :ip
      Boolean :isMobile
      Boolean :isBot
    end
  end
end
