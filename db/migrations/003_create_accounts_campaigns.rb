require 'sequel'

Sequel.migration do
  change do
    create_join_table(contributor_id: :accounts, campaign_id: :campaigns)
  end
end
