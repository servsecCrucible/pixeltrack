require 'sequel'

Sequel.migration do
  change do
    create_table(:campaigns) do
      primary_key :id
      foreign_key :owner_id, :accounts
      String :label, text: true, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
