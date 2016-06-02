require 'sequel'

Sequel.migration do
  change do
    create_join_table(contributor_id: :base_accounts, campaign_id: :campaigns)
  end
end
