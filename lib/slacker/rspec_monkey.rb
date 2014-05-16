# Monkeypatch a method to reset RSpec
module RSpec
  def self.slacker_reset
    @world = nil
    @configuration = nil
  end
end
