# Run basic test first.
load 'interactive-tests/default.rb', true
# Click a button and take a screenshot again.
$test.click_button('shake')
sleep 1
$test.save_screenshot
