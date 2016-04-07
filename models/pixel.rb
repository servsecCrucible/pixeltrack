require 'json'

# Holds a full pixel information
class Pixel
  STORE_DIR = 'public/'.freeze

  attr_accessor :id, :label, :url, :views

  def initialize(new_pixel)
    @id = new_pixel['id'] || new_id
    @label = new_pixel['label']
    @url = '/api/v1/#{@id}.png'
    @views = 0
  end

  def new_id
    Base64.urlsafe_encode64(Digest::SHA256.digest(Time.now.to_s))[0..9]
  end

  def to_json(options = {})
    JSON({ id: @id,
           label: @label,
           url: @url,
           views: @views
         },
         options)
  end

  def save
    File.open(STORE_DIR + @id + '.txt', 'w') do |file|
      file.write(to_json)
    end

    true
  rescue
    false
  end

  def self.find(find_id)
    pixel_file = File.read(STORE_DIR + find_id + '.txt')
    Pixel.new JSON.parse(pixel_file)
  end

  def self.all
    Dir.glob(STORE_DIR + '*.txt').map do |filename|
      filename.match(%r{public\/(.*)\.txt})[1]
    end
  end

  def self.setup
    Dir.mkdir(Pixel::STORE_DIR) unless Dir.exist? STORE_DIR
  end
end
