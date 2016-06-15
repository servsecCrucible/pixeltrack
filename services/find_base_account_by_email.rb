# Query all accounts and return first email match
class FindBaseAccountByEmail
  def self.call(search_email)
    BaseAccount.first(email: search_email)
  end
end
