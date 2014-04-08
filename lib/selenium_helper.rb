require 'selenium-webdriver'


module SeleniumHelper
  SAUCELABS_URL = "http://LabTests:559172dc-20ba-4b75-8918-c0e512ee843a@ondemand.saucelabs.com:80/wd/hub"
  BROWSERSTACK_URL = "http://concordconsortiu:cUEoaznXrKVPvQUb4kMy@hub.browserstack.com/wd/hub"
  SUPPORTED_BROWSERS = [:Chrome, :Safari, :Firefox, :IE9, :IE10, :iPad]

  def self.execute_on(browser, cloud, name)
    url = cloud == :SauceLabs ? SAUCELABS_URL : BROWSERSTACK_URL;
    caps = get_capabilities browser, cloud
    caps['name'] = name
    caps['max-duration'] = 10800
    driver = Selenium::WebDriver.for(:remote, :url => url, :desired_capabilities => caps)
    puts '[webdriver] created'
    #driver.manage.timeouts.implicit_wait = 60
    #driver.manage.timeouts.script_timeout = 300
    #driver.manage.timeouts.page_load = 300
    begin
      yield driver
    ensure
      puts '[webdriver] quit'
      driver.quit
    end
  end

  def self.get_capabilities(browser, cloud)
    if cloud == :SauceLabs
      case browser
      when SUPPORTED_BROWSERS[0]
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps.version = '33'
        caps.platform = 'Linux'
      when SUPPORTED_BROWSERS[1]
        caps = Selenium::WebDriver::Remote::Capabilities.safari
        caps.version = '7'
        caps.platform = 'OS X 10.9'
      when SUPPORTED_BROWSERS[2]
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps.version = '28'
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
    elsif cloud == :BrowserStack
      caps = Selenium::WebDriver::Remote::Capabilities.new
      case browser
      when SUPPORTED_BROWSERS[0]
        caps['browser'] = 'Chrome'
        caps['browser_version'] = '33.0'
        caps['os'] = 'OS X'
        caps['os_version'] = 'Mountain Lion'
      when SUPPORTED_BROWSERS[1]
        caps['browser'] = 'Safari'
        caps['browser_version'] = '7.0'
        caps['os'] = 'OS X'
        caps['os_version'] = 'Mavericks'
      when SUPPORTED_BROWSERS[2]
        caps['browser'] = 'Firefox'
        caps['browser_version'] = '27.0'
        caps['os'] = 'Windows'
        caps['os_version'] = '7'
      when SUPPORTED_BROWSERS[3]
        caps['browser'] = 'IE'
        caps['browser_version'] = '9.0'
        caps['os'] = 'Windows'
        caps['os_version'] = '7'
      when SUPPORTED_BROWSERS[4]
        caps['browser'] = 'IE'
        caps['browser_version'] = '10.0'
        caps['os'] = 'Windows'
        caps['os_version'] = '8'
      when SUPPORTED_BROWSERS[5]
        caps['browserName'] = 'iPad'
        caps['platform'] = 'MAC'
        caps['device'] = 'iPad 3rd (7.0)'
        caps['deviceOrientation'] = 'landscape'
      else
        raise 'Incorrect browser name.'
      end
    else 
      raise 'Incorrect cloud name (SauceLabs or BrowserStack expected).'
    end
    return caps
  end
end