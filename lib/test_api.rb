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
    suffix = @screenshots_count > 0 ? "_#{@screenshots_count}" : ''
    @test_helper.save_screenshot @driver, "#{@screenshot_name}#{suffix}.png", @int_url, @browser
    @screenshots_count += 1
  end

  def click_button(css_selector)
    case @browser
    when :iPad
      @driver.execute_script "$('#{css_selector}').click();"
    else
      $test.driver.find_element(:css, css_selector).click
    end
  end
end
