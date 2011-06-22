module SpecHelper
  def self.expand_test_files_path(path)
    File.expand_path("#{File.dirname(__FILE__)}/test_files/#{path}")
  end

  def self.load_csv(file)
    CSV.read(expand_test_files_path(file), {:headers => true, :encoding => 'Windows-1252'})
  end
end
