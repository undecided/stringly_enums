$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "stringly_enums"


RSpec.configure do |c|
  c.example_status_persistence_file_path = "log/rspec-run.log"
end
