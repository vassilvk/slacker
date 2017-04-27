require 'slacker'

describe Slacker::Application do
  it 'responds to run' do
    Slacker.application.should respond_to(:run)
  end

  it 'responds to target_folder_structure with the correct list of folders' do
    app = Slacker.application
    app.should respond_to(:target_folder_structure)
    folder_struct = app.target_folder_structure
    folder_struct.should == ['data', 'debug/passed_examples', 'debug/failed_examples', 'sql', 'spec', 'lib', 'lib/helpers']
  end
end