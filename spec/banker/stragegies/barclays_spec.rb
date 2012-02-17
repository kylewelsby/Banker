require 'spec_helper'

describe Banker::Stratagies::Barclays do
  before do
    stub_http_request(:get, "https://ibank.barclays.co.uk/olb/y/BasicAccessStart.do").to_return(:status => 200, :body => File.read('spec/support/barclays/BasicAccessStart.do.html'), :headers => {'Content-Type' => 'text/html'})

    stub_http_request(:post, "https://ibank.barclays.co.uk/olb/y/BasicAccessStep1.do").to_return(:status => 200, :body => File.read('spec/support/barclays/BasicAccessStep1.do.html'), :headers => {'Content-Type' => 'text/html'})

    stub_http_request(:post, "https://ibank.barclays.co.uk/olb/y/BasicAccessStep2.do").to_return(:status => 200, :body => File.read('spec/support/Barclays/BasicAccessStep2.do.html'), :headers => {'Content-Type' => 'text/html'})
  end

  subject {Banker::Stratagies::Barclays.new(:surname => 'Bloggs',
                                             :date_of_birth => Date.parse('2012-01-01'),
                                             :memorable_word => "superduper",
                                             :card_number => 4111111111111111)}

  describe '.new' do
    
    it{ subject.surname.should eql 'Bloggs' }

    it{ subject.date_of_birth.should eql Date.parse('2012-01-01') }

    it{ subject.memorable_word.should eql "superduper" }

    it{ subject.card_number.should eql 4111111111111111 }
  end

  describe '.new' do
    it "should authenticate account" do
      subject

      WebMock.should have_requested(:get, 'https://ibank.barclays.co.uk/olb/y/BasicAccessStart.do')
      WebMock.should have_requested(:post, 'https://ibank.barclays.co.uk/olb/y/BasicAccessStep1.do')
      WebMock.should have_requested(:post, 'https://ibank.barclays.co.uk/olb/y/BasicAccessStep2.do')
    end
  end

  describe '#get_data' do
    before do
      stub_request(:get, "https://ibank.barclays.co.uk/olb/y/Redirect.do?go=ExportData1.do%3Faction%3DExport%2BBank%2BStatement%7C%7CExport%2BData&Go=Go").to_return(:status => 200, :body => File.read('spec/support/Barclays/Redirect.do.html'), :headers => {'Content-Type' => 'text/html'})

      stub_request(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData1.do').to_return(:status => 200, :body => File.read('spec/support/Barclays/ExportData1.do.html'), :headers => {'Content-Type' => 'text/html'})

      stub_request(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData5.do').to_return(:status => 200, :body => File.read('spec/support/Barclays/data.ofx'), :headers => {'Content-Type' => 'text/html'})
    end
    it 'should receive account balance' do
      
      subject.get_data.account.balance.amount.should eql -1148.91
    end
  end
end
