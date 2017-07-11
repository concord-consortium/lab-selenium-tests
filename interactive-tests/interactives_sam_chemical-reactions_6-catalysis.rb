# Run basic test first.
# load 'interactive-tests/default.rb', true

$test.driver.find_element(:css=>'.lab-help-overlay').click

if ($test.driver.find_element(:id=>'lang-icon'))
  $test.select_language
end
sleep 2

$test.save_screenshot