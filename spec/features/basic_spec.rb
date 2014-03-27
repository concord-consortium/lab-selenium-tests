require 'spec_helper'
require 'json'
require 'net/http'
require 'uri'

describe 'All public curricular Lab interactives', :sauce => true do

  LAB_URL = 'http://lab.dev.concord.org/'
  interactives_to_test = []
  screenshot_paths = []
  test_dir = "screenshots/test_#{Time.now.to_i}"

  before(:all) do
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

    # Prepare screenshots/test_<timestamp> folder.
    `mkdir -p #{test_dir}`
  end

  after(:all) do
    screenshots_idx_f = File.new "#{test_dir}/index.js", 'w'
    screenshots_idx_f.puts 'var SCREENSHOTS_LIST = ['
    screenshot_paths.each_index do |i|
      screenshots_idx_f.write "  '#{screenshot_paths[i]}'"
      screenshots_idx_f.puts i < screenshot_paths.length - 1 ? ',' : '' 
    end
    screenshots_idx_f.puts '];'
    screenshots_idx_f.close
  end

  # Define actual tests.
  it 'should work without any errors for 0.5s' do
    idx = 0
    if defined? selenium
      # selenium object is defined only when tests are ran on SauceLabs.
      os_browser = '[' + selenium.config[:os] + ' ' + selenium.config[:browser]
      os_browser += ' ' + selenium.config[:browser_version] if selenium.config[:browser] == 'Internet Explorer'
      os_browser += ']'
    else
      os_browser = '[local test]'
    end
    
    interactives_to_test.each do |int_path|
      id_string = int_path + ' ' + os_browser
      puts '#' + idx.to_s + ' ' + id_string
      idx += 1
      visit LAB_URL + 'embeddable-dev.html#' + int_path
      # First, disable help tips if they are active, as they will block playback controller.
      if page.has_css?('.interactive-rendered') and page.has_css?('.lab-help-overlay')
        find('#help-icon').click
      end
      # Now try to start the simulation if the play button is available.
      if page.has_css?('.interactive-rendered') and page.has_css?('.play-pause')
        play_btn = find('.play-pause')
        if play_btn.visible?
          start_time = page.evaluate_script 'script.get("time");'
          play_btn.click
          sleep 0.5
          play_btn.click
          end_time = page.evaluate_script 'script.get("time");'
          # Additional check assuming that model has property 'time'.
          expect(end_time).to be > start_time if start_time != nil
          # Restore model to initial state.
          page.execute_script 'script.reloadModel()'
          # Ensure that play button doesn't have hover state or tooltip anymore.
          find('#interactive-container').click
        end
      end
      # Save screenshot.
      screenshot_path = "#{test_dir}/#{id_string.gsub(/[\/\s]/, '_')}.png"
      page.save_screenshot(screenshot_path)
      screenshot_paths << screenshot_path
    end
  end
end
