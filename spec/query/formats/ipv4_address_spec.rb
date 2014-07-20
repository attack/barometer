require_relative '../../spec_helper'

module Barometer::Query
  describe Format::Ipv4Address do
    describe '.is?' do
      describe 'when the query is an IPv4 address' do
        specify { expect( Format::Ipv4Address.is?('8.8.8.8') ).to be true }
        specify { expect( Format::Ipv4Address.is?('172.14.0.0') ).to be true }
        specify { expect( Format::Ipv4Address.is?('192.167.0.0') ).to be true }
      end

      describe 'when the query is not a IPv4 address' do
        specify { expect( Format::Ipv4Address.is?('') ).to be false }
        specify { expect( Format::Ipv4Address.is?(88.88) ).to be false }
        specify { expect( Format::Ipv4Address.is?('invalid') ).to be false }
        specify { expect( Format::Ipv4Address.is?('9.9.9') ).to be false }
        specify { expect( Format::Ipv4Address.is?('9.9.9.9.9') ).to be false }
        specify { expect( Format::Ipv4Address.is?('9.a.9.9') ).to be false }
      end

      describe 'when the IPv4 address is an IPv6 address' do
        specify { expect( Format::Ipv4Address.is?('3ffe:505:2::1') ).to be false }
      end

      describe 'when the IPv4 address is out of range' do
        specify { expect( Format::Ipv4Address.is?('256.0.0.0') ).to be false }
        specify { expect( Format::Ipv4Address.is?('0.256.0.0') ).to be false }
        specify { expect( Format::Ipv4Address.is?('0.0.256.0') ).to be false }
        specify { expect( Format::Ipv4Address.is?('0.0.0.256') ).to be false }
      end
    end
  end
end
