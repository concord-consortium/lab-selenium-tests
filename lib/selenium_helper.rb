require 'selenium-webdriver'


module SeleniumHelper
  SAUCELABS_URL = "http://LabTests:559172dc-20ba-4b75-8918-c0e512ee843a@ondemand.saucelabs.com:80/wd/hub"
  BROWSERSTACK_URL = "http://PiotrJanik:F7suzt0xQmJe6fZIqn2r@hub.browserstack.com/wd/hub"
  SUPPORTED_BROWSERS = ['Chrome', 'Safari', 'Firefox', 'IE9', 'IE10', 'iPad']

  def self.execute_on(browser='Chrome', cloud='SauceLabs', name='Test')
    url = cloud == 'SauceLabs' ? SAUCELABS_URL : BROWSERSTACK_URL;
    caps = get_capabilities browser, cloud
    caps[:name] = name
    driver = Selenium::WebDriver.for(:remote, :url => url, :desired_capabilities => caps)

    yield driver

    driver.quit
  end

  def self.get_capabilities(browser='Chrome', cloud='SauceLabs')
    if cloud == 'SauceLabs' # SauceLabs
      case browser
      when SUPPORTED_BROWSERS[0]
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps.version = '33'
        caps.platform = 'Linux'
      when SUPPORTED_BROWSERS[1]
        caps = Selenium::WebDriver::Remote::Capabilities.safari
        caps.version = '6'
        caps.platform = 'OS X 10.8'
      when SUPPORTED_BROWSERS[2]
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps.version = '27'
        caps.platform = 'Windows 7'
      when SUPPORTED_BROWSERS[3]
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.version = '9'
        caps.platform = 'Windows 7'
      when SUPPORTED_BROWSERS[4]
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.version = '10'
        caps.platform = 'Windows 8'
      when SUPPORTED_BROWSERS[5]
        caps = Selenium::WebDriver::Remote::Capabilities.ipad
        caps.platform = 'OS X 10.9'
        caps.version = '7.0'
        caps['device-orientation'] = 'landscape'
      else
        raise 'Incorrect browser name.'
      end
    else # BrowserStack
      caps = Selenium::WebDriver::Remote::Capabilities.new
      case browser
      when SUPPORTED_BROWSERS[0]
        caps['browser'] = 'Chrome'
        caps['browser_version'] = '33'
        caps['os'] = 'OS X'
        caps['os_version'] = 'Mountain Lion'
      when SUPPORTED_BROWSERS[1]
        caps['browser'] = 'Safari'
        caps['browser_version'] = '6.1'
        caps['os'] = 'OS X'
        caps['os_version'] = 'Mountain Lion'
      when SUPPORTED_BROWSERS[2]
        caps['browser'] = 'Firefox'
        caps['browser_version'] = '27.0'
        caps['os'] = 'WINDOWS'
        caps['os_version'] = '7'
      when SUPPORTED_BROWSERS[3]
        caps['browser'] = 'IE'
        caps['browser_version'] = '9.0'
        caps['os'] = 'WINDOWS'
        caps['os_version'] = '7'
      when SUPPORTED_BROWSERS[4]
        caps['browser'] = 'IE'
        caps['browser_version'] = '10.0'
        caps['os'] = 'WINDOWS'
        caps['os_version'] = '8'
      when SUPPORTED_BROWSERS[5]
        caps["device"] = "iPad 3rd (7.0)"
        caps["deviceOrientation"] = "landscape"
      else
        raise 'Incorrect browser name.'
      end
    end
    return caps
  end
end