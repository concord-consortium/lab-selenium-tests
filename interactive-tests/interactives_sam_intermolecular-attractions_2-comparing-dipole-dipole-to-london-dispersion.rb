# Run basic test first.
load 'interactive-tests/default.rb', true
# FIXME: Clicking doesn't work on iPad, while on Android
#        pulldown menu option can't be selected.
return if :browser == 'Android' || :browser == 'iPad'

$test.driver.find_element(:css, '.selectboxit').click
sleep 1
$test.save_screenshot
$test.driver.find_element(:css, '.selectboxit-options li:nth-child(2) a').click
sleep 1
$test.save_screenshot
$test.driver.find_element(:css, '.selectboxit').click
$test.driver.find_element(:css, '.selectboxit-options li:nth-child(3) a').click
sleep 1
$test.save_screenshot
$test.driver.find_element(:css, '.selectboxit').click
$test.driver.find_element(:css, '.selectboxit-options li:nth-child(4) a').click
sleep 1
$test.save_screenshot
