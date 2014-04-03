#!/usr/bin/env ruby
require 'optparse'
require './lib/test_helper'
require './lib/lab_helper'
require './lib/selenium_helper'

# Options and default values:
opt = {
  :browser => :Chrome,
  :lab_env => :dev,
  :cloud => :SauceLabs,
  # Number of attempts to finish the test in case of errors.
  :max_attempts => 25,
  :test_name => nil,
  :interactives_to_test => nil
}

opt_parser = OptionParser.new do |o|
  o.banner = 'Usage: test.rb [options]'
  o.separator ''
  o.separator 'Specific options:'
  o.on('-b', '--browser BROWSER',
          SeleniumHelper::SUPPORTED_BROWSERS,
          "Browser that should be tested (#{SeleniumHelper::SUPPORTED_BROWSERS.join(', ')}), default Chrome") do |browser|
    opt[:browser] = browser
  end
  o.on('-l', '--lab LAB_ENVIRONMENT',
       [:production, :staging, :dev],
       'Lab environment (production, staging or dev), default dev') do |lab_env|
    opt[:lab_env] = lab_env
  end
  o.on('-c', '--cloud CLOUD',
       [:SauceLabs, :BrowserStack],
       'Cloud environment (SauceLabs or BrowserStack), default SauceLabs') do |cloud|
    opt[:cloud] = cloud
  end
  o.on('-n', '--name NAME',
       'Test name, by default created automatically') do |name|
    opt[:test_name] = name
  end
  o.on('-a', '--attempts MAX_ATTEMPTS',
       'Maximum number of attempts to accomplish the test in case of errors, default 25') do |a|
    opt[:max_attempts] = a
  end
  o.on('-i', '--interactives i1,i2,i3',
        Array,
       'List of interactives to test, by default interactives.json is downloaded',
       'and all public, curricular interactives are tested') do |interactives|
    opt[:interactives_to_test] = interactives
  end
end

opt_parser.parse! ARGV

# Calculate some options if they are not explicitly provided.
opt[:test_name] = "#{opt[:lab_env]}_#{opt[:browser]}_#{opt[:cloud]}_#{Time.now.to_i}" if !opt[:test_name]
opt[:interactives_to_test] = LabHelper::public_curricular_interactives(opt[:lab_env]) if !opt[:interactives_to_test]

# Actual test.
test_helper = TestHelper.new opt[:test_name], opt[:interactives_to_test].length
attempt = 0
begin
  SeleniumHelper::execute_on opt[:browser], opt[:cloud], "Lab interactives screenshots generation" do |driver|
    while opt[:interactives_to_test].length > 0
      int_path = opt[:interactives_to_test][0]
      puts int_path
      int_url = LabHelper::interactive_url int_path, opt[:lab_env]
      driver.navigate.to int_url
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
      begin
        wait.until { driver.find_element(:class => 'interactive-rendered') }
      rescue Selenium::WebDriver::Error::TimeOutError
        # 'interactive-rendered' class was added in the recent Lab version. 
        # Ignore timeout in case we use the same test to get screenshots of old Lab releases.
      ensure
        sleep 1
        test_helper.save_screenshot driver, "#{int_path.gsub(/[\/\s]/, '_')}_[#{opt[:browser]}_#{opt[:cloud]}].png", int_url, opt[:browser]
      end
      # Test completed without errors, we can remove this particular interactive from list.
      opt[:interactives_to_test].shift
    end
  end
rescue => e
  puts '::ERROR::'
  puts e
  attempt += 1
  if attempt < opt[:max_attempts]
    puts "RETRYING (#{attempt})..."
    retry
  end
end
