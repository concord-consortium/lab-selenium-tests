# You should edit this file with the browsers you wish to use
# For options, check out http://saucelabs.com/docs/platforms
require 'sauce'
require 'sauce/capybara'

Capybara.default_driver = :sauce
Capybara.app_host = 'http://lab.dev.concord.org/'
Capybara.run_server = false

# Set up configuration
Sauce.config do |c|
  c[:browsers] = [
    ['Linux', 'Chrome', '33'],
    ['Windows 8', 'Internet Explorer', '10'],
    ['OS X 10.8', 'Safari', '6']
  ]
  c[:max_duration] = 10800
  c[:device_orientation] = 'landscape'
  #c[:record_video] = false
  #c[:record_screenshots] = false
end
