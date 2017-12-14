# Test if model can be run at least for 0.5s without errors. Then it's reloaded and stopped (as some models
# are automatically started in "onLoad" scripts, what would cause that screenshots would be always different).
$test.driver.execute_script 'Embeddable.controller.on("modelLoaded.selenium-test", function() { script.stop(); });' \
                            'script.start();' \
                            'setTimeout(function() { script.reloadModel(); }, 500);'

begin
  # Extra time for iframe model type.
  take_screenshot = $test.select_language #checks if language was selected and selects it returns true selected, false if flag is not present or not selected
  sleep(2)
  $test.driver.find_element(:id => 'iframe-model')
  puts 'iframe model detected, extra sleep time added...'
  sleep 15
rescue Selenium::WebDriver::Error::NoSuchElementError
  # It's present only in JSmol interactives.
end

sleep 1.5
if take_screenshot
  $test.save_screenshot
end