require 'spec_helper'
require 'json'
require "net/http"
require "uri"

describe 'Basic tests of all public curricular Lab interactives', :sauce => true do

  LAB_URL = 'http://lab.concord.org/'
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

  # Define actual tests.
  interactives_to_test.each do |int_path|
    it int_path do
      visit LAB_URL + 'embeddable-dev.html#' + int_path
      begin
        # Capybara throws an exception if the element is not found
        play_btn = find('.play-pause')
        if play_btn.visible?
          start_time = page.evaluate_script 'script.get("time");'
          play_btn.click
          sleep 0.5
          play_btn.click
          end_time = page.evaluate_script 'script.get("time");'
          # Additional check assuming that model has property 'time'.
          expect(end_time).to be > start_time if start_time != nil
        end
      rescue Capybara::ElementNotFound
        # No play button found, so the best we can get is the lack of JS errors 
        # or a screenshot on SauceLabs (assuming that we run tests there).
        true
      end 
    end
  end
end
