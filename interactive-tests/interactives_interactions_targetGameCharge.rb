# Run basic test first.
load 'interactive-tests/default.rb', true

# $test.close_about_dialog

$test.driver.execute_script('script.set("object-a-charge", -2);')
$test.driver.execute_script('script.set("object-b-charge", 1);')

$test.click_button('add-atom')
alert = $test.switch_to_alert
# Safari doesn't support alerts, nil will be returned.
alert.accept if alert
$test.save_screenshot

$test.select_radio_option('select-level', 1)
sleep 1
$test.save_screenshot

# We should fail now, charges are incorrect.
$test.click_button('add-atom')
alert = $test.switch_to_alert
alert.accept if alert
$test.save_screenshot

$test.driver.execute_script('script.set("object-b-charge", 3);')
$test.click_button('add-atom')
alert = $test.switch_to_alert
alert.accept if alert
$test.save_screenshot
