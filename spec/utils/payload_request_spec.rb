require_relative '../spec_helper'

module Barometer::Utils
  describe PayloadRequest do
    describe '#get' do
      let(:api) { double(:api, url: nil, params: nil, unwrap_nodes: [], current_query: nil) }
      let(:payload_request) { PayloadRequest.new(api) }

      before do
        allow(Get).to receive(:call).and_return(double(content: '<foo></foo>', headers: {}))
      end

      it 'makes a GET request' do
        url = double(:url)
        params = double(:params)
        allow(api).to receive_messages(url: url, params: params)

        payload_request.get

        expect( Get ).to have_received(:call).with(url, params)
      end

      it 'XML parses the GET response by default' do
        content = double(:content)
        allow(Get).to receive(:call).and_return(double(content: content, headers: {}))
        unwrap_nodes = double(:unwrap_nodes)
        allow(api).to receive(:unwrap_nodes).and_return(unwrap_nodes)
        allow(XmlReader).to receive(:parse)

        payload_request.get

        expect( XmlReader ).to have_received(:parse).with(content, unwrap_nodes)
      end

      it 'wraps the result as a payload' do
        expect( payload_request.get ).to be_a Payload
      end

      it 'stores the query used to make the request' do
        current_query = double(:query)
        allow(api).to receive(:current_query).and_return(current_query)

        payload = payload_request.get

        expect( payload.query ).to eq current_query
      end

      context 'when the returned content type is */xml' do
        it 'uses the XmlReader' do
          allow(Get).to receive(:call).
            and_return(double(content: '', headers: {'Content-Type' => 'text/xml'}))
          allow(XmlReader).to receive(:parse)

          payload_request.get

          expect( XmlReader ).to have_received(:parse)
        end
      end

      context 'when the returned content type is */json' do
        it 'uses the JsonReader' do
          allow(Get).to receive(:call).
            and_return(double(content: '', headers: {'Content-Type' => 'application/json'}))
          allow(JsonReader).to receive(:parse)

          payload_request.get

          expect( JsonReader ).to have_received(:parse)
        end
      end
    end
  end
end
