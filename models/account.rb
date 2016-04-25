require 'sequel'
require 'rbnacl/libsodium'
require 'base64'
require 'json'

# Holds and persists account information
class Account < Sequel::Model
  include SecureModel
  plugin :timestamps, update_on_create: true
  set_allowed_columns :username, :email

  
end
