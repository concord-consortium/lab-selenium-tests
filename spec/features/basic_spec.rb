require 'spec_helper'
require 'json'
require 'net/http'
require 'uri'
require 'test_helper'

describe 'Public curricular Lab interactives screenshots generation', :sauce => true do

  LAB_URL = 'http://lab.dev.concord.org/'
  interactives_to_test = []

  # Download interactives.json and populate interactives_to_test array.
  uri = URI.parse(LAB_URL + 'interactives.json')
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)

  if response.code == '200'
    result = JSON.parse(response.body)
    # Test only 'public' interactives that belong to 'Curriculum' group.
    group_key_allowed = {}
    groups = result['groups']
    groups.each do |g| 
      if g['category'] == 'Curriculum'
        group_key_allowed[g['path']] = true;
      end
    end
    result['interactives'].each do |int|
      if int['publicationStatus'] == 'public' and group_key_allowed[int['groupKey']]
        interactives_to_test << int['path'] 
      end
    end
  else
    puts LAB_URL + 'interactives.json cannot be found!'
  end

  test_helper = TestHelper.new    

  # Define actual tests.
  interactives_to_test.each do |int_path|
    it int_path do
      idx = 0
      if defined? selenium
        # selenium object is defined only when tests are ran on SauceLabs.
        os_browser = '[' + selenium.config[:os] + ' ' + selenium.config[:browser]
        os_browser += ' ' + selenium.config[:browser_version] if selenium.config[:browser] == 'Internet Explorer'
        os_browser += ']'
      else
        os_browser = '[local test]'
      end
      
      int_url = LAB_URL + 'embeddable-dev.html#' + int_path
      id_string = int_path + ' ' + os_browser
      puts '#' + idx.to_s + ' ' + id_string
      idx += 1
      visit int_url
      sleep 8
      # Save screenshot.
      test_helper.save_screenshot page, "#{id_string.gsub(/[\/\s]/, '_')}.png", int_url
    end
  end
end
