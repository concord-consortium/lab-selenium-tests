class TestAPI
  attr_reader :driver, :browser

  def initialize(driver, test_helper, interactive_path, interactive_url, browser, cloud)
    @driver = driver
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
end
