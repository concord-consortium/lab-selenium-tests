class TestAPI
  
  def initialize(driver, test_helper, interactive_path, interactive_url, browser, cloud)
    @driver = driver
    @test_helper = test_helper
    @int_path = interactive_path
    @int_url = interactive_url
    @browser = browser
    @cloud = cloud

    @screenshots_count = 0
    @screenshot_name = "#{@int_path.gsub(/[\/\s]/, '_')}_[#{@browser}_#{@cloud}]"
  end

  def save_screenshot
    suffix = @screenshots_count > 0 ? "_#{@screenshots_count}" : ''
    @test_helper.save_screenshot @driver, "#{@screenshot_name}#{suffix}.png", @int_url, @browser
    @screenshots_count += 1
  end

  attr_reader :driver
end
