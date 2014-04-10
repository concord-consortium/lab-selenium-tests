# Run basic test first.
load 'interactive-tests/default.rb', true
# Click a button and take a screenshot again.
$test.driver.find_element(:css, '#shake > button').click
sleep 1
$test.save_screenshot
