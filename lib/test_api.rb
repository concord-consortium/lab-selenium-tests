class TestAPI
  attr_reader :driver, :capybara, :browser

  def initialize(driver, capybara, test_helper, interactive_path, interactive_url, browser, cloud)
    @driver = driver
    @capybara = capybara
    @test_helper = test_helper
    @int_url = interactive_url
    @browser = browser

    @screenshots_count = 0
    @screenshot_name = "#{interactive_path.gsub(/[\/\s]/, '_')}_[#{@browser}_#{cloud}]"
  end

  def save_screenshot
    # Add time to ensure that images are loaded. It seems to be necessary only on iPad.
    sleep 1 if @browser == :iPad
    suffix = @screenshots_count > 0 ? "_#{@screenshots_count}" : ''
    @test_helper.save_screenshot @driver, "#{@screenshot_name}#{suffix}.png", @int_url, @browser
    @screenshots_count += 1
  end

  def click_element(css_selector)
    case @browser
    when :iPad
      @driver.execute_script "$('#{css_selector}').click();"
    else
      $test.driver.find_element(:css, css_selector).click
    end
  end

  # Methods specific for Lab interactive components (widgets).
  # Note that they all accept ID argument which should be equal to
  # ID specified in component definition in Interactive JSON.

  def click_button(id)
    case @browser
    when :iPad
      @driver.execute_script "$('##{id} button').click();"
    else
      $test.driver.find_element(:css, "##{id} button").click
    end
  end

  def open_pulldown(id)
    case @browser
    when :iPad
      @driver.execute_script "$('##{id} select').data('selectBox-selectBoxIt').open();"
    else
      $test.driver.find_element(:css, "##{id} .selectboxit").click
    end
  end

  def select_pulldown_option(id, option_idx)
    case @browser
    when :iPad, :Android
      @driver.execute_script "$('##{id} select').data('selectBox-selectBoxIt').close().selectOption(#{option_idx});"
    else
      $test.driver.find_element(:css, "##{id} .selectboxit-options li:nth-child(#{option_idx + 1}) a").click
    end
  end
end
