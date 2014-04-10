require 'json'
require 'net/http'
require 'uri'
require 'yaml'

module LabHelper
  LAB_URL = {
    production: 'http://lab.concord.org/',
    staging:    'http://lab-staging.concord.org/',
    dev:        'http://lab.dev.concord.org/'
  }
  INTERACTIVES_CONFIG_FILE = 'interactives-to-test.yaml'

  def self.interactive_url(int_path, env)
    LAB_URL[env] + 'embeddable.html#' + int_path
  end

  def self.interactives(env)
    config = YAML.load_file(INTERACTIVES_CONFIG_FILE)
    interactives = []
    if config['interactives.json']['enabled']
      res = filter_interactives_json(env, config['interactives.json']['category'], 
                                     config['interactives.json']['publicationStatus'])
      interactives.concat(res)
    end
    interactives.concat(config['customList']) if config['customList']
    interactives
  end

  def self.filter_interactives_json env, category_allowed, publication_status_allowed
    # Download interactives.json and return array of interactives paths that 
    # have allowed categories and publication statuses. 
    interactives = []
    interactives_json_url = "#{LAB_URL[env]}interactives.json"
    uri = URI.parse(interactives_json_url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    fail "#{interactives_json_url} cannot be found!" if response.code != '200'
    
    result = JSON.parse(response.body)
    # Test only 'public' interactives that belong to 'Curriculum' group.
    group_key_allowed = {}
    result['groups'].each do |g| 
      if category_allowed[g['category']]
        group_key_allowed[g['path']] = true;
      end
    end
    result['interactives'].each do |int|
      if publication_status_allowed[int['publicationStatus']] && group_key_allowed[int['groupKey']]
        interactives << int['path'] 
      end
    end
    interactives
  end

end
