require "bundler/setup"
require "ancestors_visualization"
require "timecop"
require "pry-byebug"
require "ruby-graphviz"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around stop_the_time: true do |example|
    Timecop.freeze
    example.run
    Timecop.return
  end

  config.before require_sample_gem: true do
    Dir.glob("#{File.expand_path('../fixtures/sample_gem_dir/lib', __FILE__)}/**/*.rb").each do |file|
      require file
    end
  end
end
