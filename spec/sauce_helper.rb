# You should edit this file with the browsers you wish to use
# For options, check out http://saucelabs.com/docs/platforms
require 'sauce'
require 'sauce/capybara'

Capybara.default_driver = :sauce

# Set up configuration
Sauce.config do |c|
  c[:browsers] = [
    ['Linux', 'Chrome', nil]
  ]
end
