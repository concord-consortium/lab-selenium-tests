require 'json'
require 'net/http'
require 'uri'

module LabHelper
  LAB_URL = {
    :production => 'http://lab.concord.org/',
    :staging    => 'http://lab-staging.concord.org/',
    :dev        => 'http://lab.dev.concord.org/'
  }

  def self.interactive_url(int_path, env)
    LAB_URL[env] + 'embeddable.html#' + int_path
  end

  def self.public_curricular_interactives(env)
    # Download interactives.json and return array of public, curricular interactives paths.
    interactives = []

    uri = URI.parse(LAB_URL[env] + 'interactives.json')
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
          interactives << int['path'] 
        end
      end
    else
      puts LAB_URL[env] + 'interactives.json cannot be found!'
    end
    return interactives
  end
end
