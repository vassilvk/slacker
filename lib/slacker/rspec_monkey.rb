# Monkeypatch a method to reset RSpec to reset it
module RSpec
  def self.slacker_reset
    @world = nil
    @configuration = nil
  end
end