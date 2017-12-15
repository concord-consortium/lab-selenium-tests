# Test if model can be run at least for 0.5s without errors. Then it's reloaded and stopped (as some models
# are automatically started in "onLoad" scripts, what would cause that screenshots would be always different).
def visible
  style = $test.driver.find_element(:css=>'.about-dialog').attribute("style")
  if style.include?('block')
    return true
  else
    return false
  end

end

$test.driver.execute_script 'Embeddable.controller.on("modelLoaded.selenium-test", function() { script.stop(); });' \
                            'script.start();' \
                            'setTimeout(function() { script.reloadModel(); }, 500);'
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

close_dialog_size = $test.driver.find_elements(:css=>'.about-dialog > .ui-dialog-titlebar > .ui-dialog-titlebar-close').size #checks to see if there is an about dialog
if close_dialog_size > 0 && visible #some interactives have hidden about dialogs so have to check if they are visible
    puts "about box is visible"
  $test.driver.find_element(:css=>'.about-dialog > .ui-dialog-titlebar > .ui-dialog-titlebar-close').click
  sleep 1.5
  $test.save_screenshot
end