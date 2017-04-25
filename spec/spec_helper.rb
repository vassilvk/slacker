module SpecHelper

  RSpec.configure do |config|
    config.expect_with :rspec do |c|
      c.syntax = :should
    end
    config.mock_with :rspec do |c|
      c.syntax = :should
    end    
  end

  def self.expand_test_files_path(path)
    File.expand_path("#{File.dirname(__FILE__)}/test_files/#{path}")
  end

  def self.load_csv(file)
    CSV.read(expand_test_files_path(file), {:headers => true, :encoding => 'Windows-1252'})
  end
end
