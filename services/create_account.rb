# Service object to create new accounts using all columns
class CreateAccount
  def self.call(signed_full_registration)
    registration = SecureClientMessage.verified_data(signed_full_registration)
    create_new_account(registration)
  end

  def self.create_new_account(registration)
    account = Account.new(username: registration['username'])
    account.email = registration['email']
    account.password = registration['password']
    account.save
  end
end
