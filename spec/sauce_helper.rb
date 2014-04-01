# You should edit this file with the browsers you wish to use
# For options, check out http://saucelabs.com/docs/platforms
require 'sauce'

# Set up configuration
Sauce.config do |c|
  c[:browsers] = [
    ['OS X 10.8', 'Safari', '6']
    #['Windows 7', 'Internet Explorer', '9'],
    #['Linux', 'Chrome', '33']
  ]
  c[:max_duration] = 10800
  #c[:record_video] = false
  #c[:record_screenshots] = false
end
