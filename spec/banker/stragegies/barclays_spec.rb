require 'spec_helper'

describe Banker::Stratagies::Barclays do
  let(:basic_access_start) { File.read(File.expand_path('../../../support/barclays/BasicAccessStart.do.html',__FILE__)) }
  let(:basic_access_step1) { File.read(File.expand_path('../../../support/barclays/BasicAccessStep1.do.html',__FILE__)) }
  let(:basic_access_step2) { File.read(File.expand_path('../../../support/barclays/BasicAccessStep2.do.html',__FILE__)) }
  let(:redirect) { File.read(File.expand_path('../../../support/barclays/Redirect.do.html',__FILE__)) }
  let(:export_data1) { File.read(File.expand_path('../../../support/barclays/ExportData1.do.html',__FILE__)) }
  let(:data) { File.read(File.expand_path('../../../support/barclays/data.ofx',__FILE__)) }

  before do
    stub_request(:get, "https://ibank.barclays.co.uk/olb/y/BasicAccessStart.do").to_return(:status => 200, :body => basic_access_start, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, "https://ibank.barclays.co.uk/olb/y/BasicAccessStep1.do").to_return(:status => 200, :body => basic_access_step1, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, "https://ibank.barclays.co.uk/olb/y/BasicAccessStep2.do").to_return(:status => 200, :body => basic_access_step2, :headers => {'Content-Type' => 'text/html'})


    stub_request(:get, "https://ibank.barclays.co.uk/olb/y/Redirect.do?go=ExportData1.do%3Faction%3DExport%2BBank%2BStatement%7C%7CExport%2BData&Go=Go").to_return(:status => 200, :body => redirect, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData1.do').to_return(:status => 200, :body => export_data1, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData5.do').to_return(:status => 200, :body => data, :headers => {'Content-Type' => 'text/html'})

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

    it{ subject.balance.should eql 410010 }

    it "should authenticate account" do
      subject

      WebMock.should have_requested(:get, 'https://ibank.barclays.co.uk/olb/y/BasicAccessStart.do')
      WebMock.should have_requested(:post, 'https://ibank.barclays.co.uk/olb/y/BasicAccessStep1.do')
      WebMock.should have_requested(:post, 'https://ibank.barclays.co.uk/olb/y/BasicAccessStep2.do')

      WebMock.should have_requested(:get, 'https://ibank.barclays.co.uk/olb/y/Redirect.do?go=ExportData1.do%3Faction%3DExport%2BBank%2BStatement%7C%7CExport%2BData&Go=Go')
      WebMock.should have_requested(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData1.do')
      WebMock.should have_requested(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData5.do')
    end
  end
end
