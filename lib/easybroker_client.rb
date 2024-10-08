# lib/easybroker_client.rb
require 'faraday'
require 'json'

module EasyBroker
  class Client
    BASE_URL = 'https://api.stagingeb.com/v1'.freeze

    def initialize(api_key)
      @api_key = api_key
    end

    def get_properties
      fetch_all_pages('/properties')
    end

    def print_property_titles
      get_properties.each { |property| puts property['title'] }
    end

    private

    def fetch_all_pages(endpoint, params = {})
      items = []
      page = 1

      loop do
        response = make_request(endpoint, params.merge(page: page, limit: 50))
        data = JSON.parse(response.body)

        items += data['content']
        break if data['pagination']['next_page'].nil?

        page += 1
      end

      items
    end

    def make_request(endpoint, params = {})
      connection.get(endpoint, params)
    end

    def connection
      @connection ||= Faraday.new(BASE_URL) do |conn|
        conn.headers['X-Authorization'] = @api_key
        conn.headers['Accept'] = 'application/json'
        conn.adapter Faraday.default_adapter
      end
    end
  end
end

