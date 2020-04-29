# Run basic test first.
load 'interactive-tests/default.rb', true

$test.click_element('.play-pause')
sleep 5
$test.save_screenshot