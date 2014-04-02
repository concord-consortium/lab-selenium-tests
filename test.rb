require './lib/test_helper'
require './lib/lab_helper'
require './lib/selenium_helper'

# Command line arguments:
browser = ARGV[0] || 'Chrome'
cloud = case ARGV[1] 
  when nil then 'SauceLabs'
  when 'S' then 'SauceLabs'
  when 'B' then 'BrowserStack'
  else ARGV[1]
end
test_name = ARGV[2] || "#{browser}_#{cloud}_#{Time.now.to_i}"

# Helpers and test data:
test_helper = TestHelper.new test_name
interactives_to_test = LabHelper::public_curricular_interactives

# Actual test:
SeleniumHelper::execute_on browser, cloud, "Test of public, curricular Lab interactives" do |driver|
  interactives_to_test.each do |int_path|
    puts int_path
    int_url = LabHelper::interactive_url int_path
    driver.navigate.to int_url
    wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
    begin
      wait.until { driver.find_element(:class => 'interactive-rendered') }
    rescue Selenium::WebDriver::Error::TimeOutError
      # 'interactive-rendered' class was added in the recent Lab version. 
      # Ignore timeout in case we use the same test to get screenshots of old Lab releases.
    ensure
      sleep 1
      test_helper.save_screenshot driver, "#{int_path.gsub(/[\/\s]/, '_')}_[#{browser}].png", int_url
    end
  end
end
