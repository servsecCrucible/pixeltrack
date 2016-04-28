# Service object to create new tracker using
class CreateNewTracker
  def self.call(label:)
    tracker = Tracker.new(label: label)
    tracker.save
  end
end
