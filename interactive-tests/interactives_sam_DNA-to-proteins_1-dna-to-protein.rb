# Initial cells view.
$test.save_screenshot

$test.click_button('#next-state-jump > button')
$test.save_screenshot

$test.click_button('#next-state-jump > button')
$test.save_screenshot

$test.click_button('#next-state-jump > button')
$test.save_screenshot

$test.click_button('#next-state-jump > button')
$test.save_screenshot
# DNA strands.
$test.click_button('#next-state-jump > button')
$test.save_screenshot
# Separated DNA.
$test.click_button('#next-state-jump > button')
$test.save_screenshot

# Test animation ()
$test.click_button('#transcribe-step > button')
$test.save_screenshot

# Complete transcription.
32.times do
  $test.click_button('#next-state-jump > button')
end
$test.save_screenshot

# Animation till the end of transcription.
$test.click_button('#transcribe > button')
sleep 2
$test.save_screenshot

$test.click_button('#next-state-jump > button')
$test.save_screenshot

$test.click_button('#next-state-jump > button')
$test.save_screenshot

$test.click_button('#next-state-jump > button')
$test.save_screenshot

# Translation animation.
$test.click_button('#translate-step > button')
sleep 2
$test.save_screenshot

# Use scripting API and stop the model when transition is done. Note that this step is
# not deterministic and image comparison will probably show some differences during each test.
$test.driver.execute_script 'script.translateDNAStep(); setTimeout(function() { script.stop(); }, 2000);'
sleep 2.5
$test.save_screenshot

$test.driver.execute_script 'script.jumpToNextDNAState(); script.stop();'
$test.save_screenshot
