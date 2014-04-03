require './lib/test_helper'
require './lib/lab_helper'
require './lib/selenium_helper'

# Number of attempts to finish the test in case of errors.
MAX_ATTEMPTS = 25

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
attempt = 0
# Actual test:
begin
  SeleniumHelper::execute_on browser, cloud, "Test of public, curricular Lab interactives" do |driver|
    while interactives_to_test.length > 0
      int_path = interactives_to_test[0]
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
        test_helper.save_screenshot driver, "#{int_path.gsub(/[\/\s]/, '_')}_[#{browser}_#{cloud}].png", int_url, browser
      end
      # Test completed without errors, we can remove this particular interactive from list.
      interactives_to_test.shift
    end
  end
rescue => e
  puts '::ERROR::'
  puts e
  attempt += 1
  if attempt < MAX_ATTEMPTS
    puts "RETRYING (#{attempt})..."
    retry
  end
end
