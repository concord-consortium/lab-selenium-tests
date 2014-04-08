require 'selenium-webdriver'


module SeleniumHelper
  SAUCELABS_URL = "http://LabTests:559172dc-20ba-4b75-8918-c0e512ee843a@ondemand.saucelabs.com:80/wd/hub"
  BROWSERSTACK_URL = "http://concordconsortiu:cUEoaznXrKVPvQUb4kMy@hub.browserstack.com/wd/hub"
  SUPPORTED_BROWSERS = [:Chrome, :Safari, :Firefox, :IE9, :IE10, :IE11, :iPad, :Android]
  SUPPORTED_PLATFORMS = [:OSX_10_8, :OSX_10_9, :Win_7, :Win_8, :Win_8_1, :Linux]
  DEFAULT_PLATFORM = {
    :Chrome => :OSX_10_8,
    :Safari => :OSX_10_9,
    :Firefox => :Win_7,
    :IE9 => :Win_7,
    :IE10 => :Win_8,
    :IE11 => :Win_8_1,
    :iPad => nil,
    :Android => nil
  }

  def self.execute_on(browser, platform, cloud, name)
    url = cloud == :SauceLabs ? SAUCELABS_URL : BROWSERSTACK_URL;
    # Each browser has its default platform, however client code can enforce specific one.
    platform ||= DEFAULT_PLATFORM[browser]
    caps = get_capabilities browser, cloud

    set_platform caps, platform, cloud if platform != nil # e.g. iPad doesn't need it.
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
      when SUPPORTED_BROWSERS[1]
        caps = Selenium::WebDriver::Remote::Capabilities.safari
        caps.version = '7'
      when SUPPORTED_BROWSERS[2]
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps.version = '28'
      when SUPPORTED_BROWSERS[3]
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.version = '9'
      when SUPPORTED_BROWSERS[4]
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.version = '10'
      when SUPPORTED_BROWSERS[5]
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.version = '11'
      when SUPPORTED_BROWSERS[6]
        caps = Selenium::WebDriver::Remote::Capabilities.ipad
        caps.platform = 'OS X 10.9'
        caps.version = '7.0'
        caps['device-orientation'] = 'landscape'
      when SUPPORTED_BROWSERS[7]
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps.platform = 'Linux'
        caps.version = '4.3'
        caps['device-type'] = 'tablet'
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
      when SUPPORTED_BROWSERS[1]
        caps['browser'] = 'Safari'
        caps['browser_version'] = '7.0'
      when SUPPORTED_BROWSERS[2]
        caps['browser'] = 'Firefox'
        caps['browser_version'] = '27.0'
      when SUPPORTED_BROWSERS[3]
        caps['browser'] = 'IE'
        caps['browser_version'] = '9.0'
      when SUPPORTED_BROWSERS[4]
        caps['browser'] = 'IE'
        caps['browser_version'] = '10.0'
      when SUPPORTED_BROWSERS[5]
        caps['browser'] = 'IE'
        caps['browser_version'] = '11.0'  
      when SUPPORTED_BROWSERS[5]
        caps['browserName'] = 'iPad'
        caps['platform'] = 'MAC'
        caps['device'] = 'iPad 3rd (7.0)'
        caps['deviceOrientation'] = 'landscape'
      when SUPPORTED_BROWSERS[5]
        caps['browserName'] = 'android'
        caps['platform'] = 'ANDROID'
        caps['device'] = 'Google Nexus 7'
        caps['deviceOrientation'] = 'landscape'
      else
        raise 'Incorrect browser name.'
      end
    else 
      raise 'Incorrect cloud name (SauceLabs or BrowserStack expected).'
    end
    return caps
  end

  def self.set_platform(caps, platform, cloud) 
    if cloud == :SauceLabs
      case platform
      when SUPPORTED_PLATFORMS[0]
        caps.platform = 'OS X 10.8'
      when SUPPORTED_PLATFORMS[1]
        caps.platform = 'OS X 10.9'
      when SUPPORTED_PLATFORMS[2]
        caps.platform = 'Windows 7'
      when SUPPORTED_PLATFORMS[3]
        caps.platform = 'Windows 8'
      when SUPPORTED_PLATFORMS[4]
        caps.platform = 'Windows 8.1'
      when SUPPORTED_PLATFORMS[5]
        caps.platform = 'Linux'
      else
        raise 'Incorrect platform (OS) name.'
      end
    elsif cloud == :BrowserStack
      case platform
      when SUPPORTED_PLATFORMS[0]
        caps['os'] = 'OS X'
        caps['os_version'] = 'Mountain Lion'
      when SUPPORTED_PLATFORMS[1]
        caps['os'] = 'OS X'
        caps['os_version'] = 'Mavericks'
      when SUPPORTED_PLATFORMS[2]
        caps['os'] = 'Windows'
        caps['os_version'] = '7'
      when SUPPORTED_PLATFORMS[3]
        caps['os'] = 'Windows'
        caps['os_version'] = '8'
      when SUPPORTED_PLATFORMS[4]
        caps['os'] = 'Windows'
        caps['os_version'] = '8.1'
      when SUPPORTED_PLATFORMS[5]
        raise 'Linux is not supported on BrowserStack.'
      else
        raise 'Incorrect platform (OS) name.'
      end
    else 
      raise 'Incorrect cloud name (SauceLabs or BrowserStack expected).'
    end
    return caps
  end
end