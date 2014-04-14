# Initial cells view.
$test.save_screenshot

# Issues on iPad, can't click button correctly.
unless $test.browser == :iPad
  next_step = $test.driver.find_element(:css, '#next-state-jump > button')

  next_step.click
  $test.save_screenshot

  next_step.click
  $test.save_screenshot

  next_step.click
  $test.save_screenshot

  next_step.click
  $test.save_screenshot
  # DNA strands.
  next_step.click
  $test.save_screenshot
  # Separated DNA.
  next_step.click
  $test.save_screenshot

  # Test animation ()
  $test.driver.find_element(:css, '#transcribe-step > button').click
  $test.save_screenshot

  # Complete transcription.
  32.times do
    next_step.click
  end
  $test.save_screenshot

  # Animation till the end of transcription.
  $test.driver.find_element(:css, '#transcribe > button').click
  sleep 2
  $test.save_screenshot

  next_step.click
  $test.save_screenshot

  next_step.click
  $test.save_screenshot

  next_step.click
  $test.save_screenshot

  # Translation animation.
  $test.driver.find_element(:css, '#translate-step > button').click
  sleep 2
  $test.save_screenshot

  # Use scripting API and stop the model when transition is done. Note that this step is
  # not deterministic and image comparison will probably show some differences during each test.
  $test.driver.execute_script 'script.translateDNAStep(); setTimeout(function() { script.stop(); }, 2000);'
  sleep 2.5
  $test.save_screenshot

  $test.driver.execute_script 'script.jumpToNextDNAState(); script.stop();'
  $test.save_screenshot
end
