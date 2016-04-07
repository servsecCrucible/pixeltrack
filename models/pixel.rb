require 'json'

# Holds a full pixel information
class Pixel
  STORE_DIR = 'public/'.freeze

  attr_accessor :id

  def initialize(new_pixel)
    @id = new_pixel['id'] || new_id
  end

  def new_id
    Base64.urlsafe_encode64(Digest::SHA256.digest(Time.now.to_s))[0..9]
  end

  def self.setup
    Dir.mkdir(Pixel::STORE_DIR) unless Dir.exist? STORE_DIR
  end
end

