require 'json'
require 'net/http'
require 'uri'
require 'yaml'

module LabHelper
  LAB_URL = 'http://lab.concord.org/branch/codap-default-export/'
  CUSTOM_CONFIG = 'interactives-to-test.yaml'
  DEFAULT_CONFIG = 'interactives-to-test.default.yaml'
  EMBEDDABLE = {
    default:    'embeddable.html',
    production: 'embeddable-production.html',
    staging:    'embeddable-staging.html',
    dev:        'embeddable-dev.html'
  }
  module_function

  def interactive_url(int_path, env)
    LAB_URL + EMBEDDABLE[env] + '#' + int_path
  end

  def interactives
    config = File.file?(CUSTOM_CONFIG) ? YAML.load_file(CUSTOM_CONFIG) : YAML.load_file(DEFAULT_CONFIG)
    interactives = []
    if config['interactives.json']['enabled']
      res = filter_interactives_json(config['interactives.json']['category'],
                                     config['interactives.json']['publicationStatus'])
      interactives.concat(res)
    end
    interactives.concat(config['customList']) if config['customList']
    interactives
  end

  def filter_interactives_json(category_allowed, status_allowed)
    # Download interactives.json and return array of interactives paths that
    # have allowed categories and publication statuses.
    interactives = []
    interactives_json_url = "#{LAB_URL}interactives.json"
    uri = URI.parse(interactives_json_url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    fail "#{interactives_json_url} cannot be found!" if response.code != '200'

    result = JSON.parse(response.body)
    # Test only 'public' interactives that belong to 'Curriculum' group.
    group_key_allowed = {}
    result['groups'].each do |g|
      group_key_allowed[g['path']] = true if category_allowed[g['category']]
    end
    result['interactives'].each do |int|
      if status_allowed[int['publicationStatus']] && group_key_allowed[int['groupKey']]
        interactives << int['path']
      end
    end
    interactives
  end
end
