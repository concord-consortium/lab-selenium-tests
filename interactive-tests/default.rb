# Test if model can be run at least for 0.5s without errors. Then it's reloaded and stopped (as some models
# are automatically started in "onLoad" scripts, what would cause that screenshots would be always different).
puts "in default.rb"
$test.driver.execute_script 'Embeddable.controller.on("modelLoaded.selenium-test", function() { script.stop(); });' \
                            'script.start();' \
                            'setTimeout(function() { script.reloadModel(); }, 500);'
puts "after javascript"                          
begin
  # Extra time for iframe model type.
  $test.driver.find_element(:id => 'iframe-model')
  puts 'iframe model detected, extra sleep time added...'
  sleep 15
rescue Selenium::WebDriver::Error::NoSuchElementError
  # It's present only in JSmol interactives.
end
sleep 1.5
$test.save_screenshot

if $test.check_about_dialog_is_present  #some interactives have hidden about dialogs so have to check if they are visible
  $test.close_about_dialog
  sleep 1.5
  $test.save_screenshot
end