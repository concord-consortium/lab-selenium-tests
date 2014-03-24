require 'capybara/dsl'
require 'capybara/rspec'

if ENV["LOCAL_SELENIUM"]
  require 'local_helper'
else
  require 'sauce_helper'
end

RSpec.configure do |config|
  config.include Capybara::DSL

  config.formatter = :documentation
  config.color_enabled = true
  #config.fail_fast = true
end
