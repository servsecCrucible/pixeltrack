require 'sequel'

Sequel.migration do
  change do
    create_table(:trackers) do
      String :id, type: :uuid, primary_key: true
      foreign_key :campaign_id

      String :label, null: false
      String :url, unique: true

      unique [:campaign_id, :label]
    end
  end
end

