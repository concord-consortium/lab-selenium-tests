# Run basic test first.
load 'interactive-tests/default.rb', true
$test.click_element('#help-icon')
$test.save_screenshot
$test.select_radio_option('select-level', 1)
sleep 1
$test.save_screenshot
