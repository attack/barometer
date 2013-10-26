require_relative '../spec_helper'

module Barometer
  describe Utils::Get do
    describe '.call' do
      it 'gets http content from a given address' do
        stub_request(:get, 'www.example.com?foo=bar').to_return(body: 'Hello World')

        response = Utils::Get.call('www.example.com', foo: :bar)
        expect( response.content ).to include('Hello World')
      end

      it 'raises Barometer::TimeoutError when it times out' do
        stub_request(:get, 'www.example.com').to_timeout

        expect {
          Utils::Get.call('www.example.com')
        }.to raise_error(Barometer::TimeoutError)
      end
    end
  end
end
