require 'sequel'
require 'rbnacl/libsodium'
require 'base64'
require 'json'

# Holds and persists account information
class Account < Sequel::Model
  include SecureModel
  plugin :timestamps, update_on_create: true
  set_allowed_columns :username, :email

  one_to_many :owned_campaigns, class: :Campaign, key: :owner_id
  many_to_many :campaigns,
               join_table: :accounts_campaigns,
               left_key: :contributor_id, right_key: :campaign_id

  plugin :association_dependencies, owned_campaigns: :destroy

  def password=(new_password)
    nacl = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    digest = hash_password(nacl, new_password)
    self.salt = Base64.urlsafe_encode64(nacl)
    self.password_hash = Base64.urlsafe_encode64(digest)
  end

  def password?(try_password)
    nacl = Base64.urlsafe_decode64(salt)
    try_digest = hash_password(nacl, try_password)
    try_password_hash = Base64.urlsafe_encode64(try_digest)
    try_password_hash == password_hash
  end

  def to_json(options = {})
    JSON({  type: 'account',
            username: username
          },
         options)
  end


end
