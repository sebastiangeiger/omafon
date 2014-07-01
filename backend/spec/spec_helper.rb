require_relative '../app/my_logger'
RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.before(:all) do
    MyLogger.log_to = STDOUT if RSpec::world.example_count == 1
  end
end
