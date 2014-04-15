# Run basic test first.
load 'interactive-tests/default.rb', true
$test.driver.execute_script 'script.loadModel("level2");'
sleep 1
$test.save_screenshot
