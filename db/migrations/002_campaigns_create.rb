require 'sequel'

Sequel.migration do
  change do
    create_table(:campaigns) do
      primary_key :id

      String :label_encrypted, text: true, null: false
    end
  end
end
