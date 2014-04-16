# Run basic test first.
load 'interactive-tests/default.rb', true

$test.open_pulldown('pulldown1')
# Note that on mobile devies (iPad, Anroid), pulldown menu won't be visible on
# this screenshot (perhaps because it's a native one).
$test.save_screenshot
$test.select_pulldown_option('pulldown1', 1)
sleep 1
$test.save_screenshot
$test.open_pulldown('pulldown1')
$test.select_pulldown_option('pulldown1', 2)
sleep 1
$test.save_screenshot
$test.open_pulldown('pulldown1')
$test.select_pulldown_option('pulldown1', 3)
sleep 1
$test.save_screenshot
