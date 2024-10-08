# spec/easybroker_client_spec.rb
require 'spec_helper'

RSpec.describe EasyBroker::Client do
  let(:api_key) { 'test_api_key' }
  let(:client) { described_class.new(api_key) }

  describe '#initialize' do
    it 'creates a client with the given API key' do
      expect(client.instance_variable_get(:@api_key)).to eq(api_key)
    end
  end

  describe '#get_properties' do
    context 'when the request is successful' do
      it 'fetches all properties' do
        VCR.use_cassette('get_properties_success') do
          properties = client.get_properties
          expect(properties).to be_an(Array)
          expect(properties).not_to be_empty
          expect(properties.first).to have_key('title')
        end
      end

      it 'handles pagination correctly' do
        VCR.use_cassette('get_properties_pagination') do
          properties = client.get_properties
          expect(properties.length).to be > 50 # Assuming more than one page of results
        end
      end
    end

    context 'when the request fails' do
      it 'raises an error for invalid API key' do
        VCR.use_cassette('get_properties_invalid_key') do
          client = described_class.new('invalid_key')
          expect { client.get_properties }.to raise_error(Faraday::ClientError)
        end
      end

      it 'raises an error for server errors' do
        stub_request(:get, /#{EasyBroker::Client::BASE_URL}/).to_return(status: 500)
        expect { client.get_properties }.to raise_error(Faraday::ServerError)
      end
    end
  end

  describe '#print_property_titles' do
    it 'prints property titles to stdout' do
      properties = [
        { 'title' => 'Beautiful House' },
        { 'title' => 'Cozy Apartment' }
      ]
      allow(client).to receive(:get_properties).and_return(properties)

      expect { client.print_property_titles }.to output(
        "Beautiful House\nCozy Apartment\n"
      ).to_stdout
    end

    it 'handles empty property list' do
      allow(client).to receive(:get_properties).and_return([])
      expect { client.print_property_titles }.to output("").to_stdout
    end
  end

  describe 'private methods' do
    describe '#fetch_all_pages' do
      it 'fetches all pages of results' do
        allow(client).to receive(:make_request).and_return(
          double(body: JSON.generate({
            'content' => [{ 'id' => 1 }],
            'pagination' => { 'next_page' => 2 }
          })),
          double(body: JSON.generate({
            'content' => [{ 'id' => 2 }],
            'pagination' => { 'next_page' => nil }
          }))
        )

        result = client.send(:fetch_all_pages, '/test')
        expect(result).to eq([{ 'id' => 1 }, { 'id' => 2 }])
      end
    end

    describe '#make_request' do
      it 'makes a GET request with correct headers' do
        stub = stub_request(:get, "#{EasyBroker::Client::BASE_URL}/test")
               .with(headers: {
                 'X-Authorization' => api_key,
                 'Accept' => 'application/json'
               })
               .to_return(status: 200, body: '{}')

        client.send(:make_request, '/test')
        expect(stub).to have_been_requested
      end
    end
  end
end