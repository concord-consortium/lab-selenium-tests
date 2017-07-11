require 'selenium-webdriver'
require 'capybara'
require 'appium_lib'
require 'appium_capybara'

module SeleniumHelper
  SUPPORTED_BROWSERS = [:Chrome, :Safari, :Firefox, :IE9, :IE10, :IE11, :iPad, :Android, :Edge]
  SUPPORTED_PLATFORMS = [:OSX_10_8, :OSX_10_9, :Win_7, :Win_8, :Win_8_1, :Linux, :Win_10]
  DEFAULT_PLATFORM = {
    Chrome: :Win_7,
    Safari: :OSX_10_9,
    Firefox: :Win_7,
    IE9: :Win_7,
    IE10: :Win_7,
    IE11: :Win_8_1,
    Edge: :Win_10,
    iPad: nil,
    Android: nil
  }
  CLOUD_URL = {
    SauceLabs: 'http://LabTests:559172dc-20ba-4b75-8918-c0e512ee843a@ondemand.saucelabs.com:80/wd/hub',
    # SauceLabs: 'http://eireland:b64ffb1e-a71d-40db-a73c-67a8b43620b6@ondemand.saucelabs.com:80/wd/hub',
    BrowserStack: 'http://concordconsortiu:cUEoaznXrKVPvQUb4kMy@hub.browserstack.com/wd/hub',
    local: nil
  }

  # Monkey patching, issue described here:
  # https://groups.google.com/forum/#!topic/ruby-capybara/tZi2F306Fvo
  class Capybara::Selenium::Driver
    def clear_browser
      @browser = nil
    end
  end

  module_function

  def execute_on(browser, platform, cloud, name)
    capybara =
      if cloud != :local
        url = CLOUD_URL[cloud]
        # Each browser has its default platform, however client code can enforce specific one.
        platform ||= DEFAULT_PLATFORM[browser]
        caps = get_capabilities(browser, cloud)
        set_platform(caps, platform, cloud) if platform
        caps['name'] = name
        caps['max-duration'] = 10_800
        Capybara.register_driver :remote_browser do |app|
          Capybara::Selenium::Driver.new(app, browser: :remote, url: url, desired_capabilities: caps)
        end
        Capybara::Session.new(:remote_browser)
      else
        Capybara::Session.new(:selenium)
      end
    driver = capybara.driver.browser
    puts '[webdriver] created'
    # driver.manage.timeouts.implicit_wait = 60
    # driver.manage.timeouts.script_timeout = 300
    # driver.manage.timeouts.page_load = 300
    begin
      yield driver, capybara
    ensure
      puts '[webdriver] quit'
      capybara.driver.quit
      capybara.driver.clear_browser
    end
  end

  def get_capabilities(browser, cloud)
    if cloud == :SauceLabs
      case browser
      when SUPPORTED_BROWSERS[0]
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps.version = 'latest'
      when SUPPORTED_BROWSERS[1]
        caps = Selenium::WebDriver::Remote::Capabilities.safari
        caps.version = '7'
      when SUPPORTED_BROWSERS[2]
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps.version = 'latest'
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
        caps = Selenium::WebDriver::Remote::Capabilities.safari
        caps['appiumVersion'] = '1.6.3'
        caps['deviceName'] = 'iPad Simulator'
        caps['platformName'] = 'iOS'
        caps['platformVersion'] = '9.3'
        caps['deviceOrientation'] = 'landscape'
        caps['browserName'] = 'Safari'
        caps['rotatable'] = true
      when SUPPORTED_BROWSERS[7] #Need an Android Emulator that runs Chrome instead of generic Browser
        caps = Selenium::WebDriver::Remote::Capabilities.new
        caps['appiumVersion'] = '1.6.3'
        caps['platformName'] = 'Android'
        caps['platformVersion'] = '6.0'
        caps['browserName'] ='Chrome'
        caps['deviceName'] = 'Android Emulator'
        caps['deviceOrientation'] = 'landscape'
        caps['nativeWebScreenshot'] = true
        caps['rotatable'] = true
      when SUPPORTED_BROWSERS[8]
          caps = Selenium::WebDriver::Remote::Capabilities.edge
          caps['version'] = '13.10586'
          caps['platform'] = 'Windows 10'
      else
        fail 'Incorrect browser name.'
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
      when SUPPORTED_BROWSERS[6]
        caps['browserName'] = 'iPad'
        caps['platform'] = 'MAC'
        caps['device'] = 'iPad 3rd (7.0)'
        caps['deviceOrientation'] = 'landscape'
      when SUPPORTED_BROWSERS[7]
        caps['browserName'] = 'android'
        caps['platform'] = 'ANDROID'
        caps['device'] = 'Google Nexus 7'
        caps['deviceOrientation'] = 'landscape'
      else
        fail 'Incorrect browser name.'
      end
    else
      fail 'Incorrect cloud name (SauceLabs or BrowserStack expected).'
    end
    caps
  end

  def set_platform(caps, platform, cloud)
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
        when SUPPORTED_PLATFORMS[6]
          caps.platform = 'Windows 10'
      else
        fail 'Incorrect platform (OS) name.'
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
        fail 'Linux is not supported on BrowserStack.'
      else
        fail 'Incorrect platform (OS) name.'
      end
    else
      fail 'Incorrect cloud name (SauceLabs or BrowserStack expected).'
    end
    caps
  end
end


