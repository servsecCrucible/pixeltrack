require 'base64'
require 'rbnacl/libsodium'

# Makes a model EncryptableModel
# - Required: model must have nonce attribute
module SecureModel
  def key
    @key ||= Base64.strict_decode64(ENV['DB_KEY'])
  end

  def encrypt(plaintext)
    if plaintext
      simple_box = RbNaCl::SimpleBox.from_secret_key(key)
      ciphertext = simple_box.encrypt(plaintext)
      #secret_box = RbNaCl::SecretBox.new(key)
      #new_once = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
      #ciphertext = secret_box.encrypt(new_once, plaintext)
      #self.nonce = Base64.strict_encode64(new_once)
      Base64.strict_encode64(ciphertext)
    end
  end

  def decrypt(encrypted)
    if encrypted
      simple_box = RbNaCl::SimpleBox.from_secret_key(key)
      ciphertext = Base64.strict_decode64(encrypted)
      simple_box.decrypt(ciphertext)

      #secret_box = RbNaCl::SecretBox.new(key)
      #old_nonce = Base64.strict_decode64(nonce)
      #ciphertext = Base64.strict_decode64(encrypted)
      #secret_box.decrypt(old_nonce, ciphertext)
    end
  end
end
