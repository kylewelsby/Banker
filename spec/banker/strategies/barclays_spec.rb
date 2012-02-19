require 'spec_helper'

describe Banker::Strategies::Barclays do
  let(:support_files) {File.expand_path('../../../support/barclays/',__FILE__)}

  let(:basic_access_start) { File.read(File.expand_path('BasicAccessStart.do.html',support_files)) }
  let(:basic_access_step1) { File.read(File.expand_path('BasicAccessStep1.do.html',support_files)) }
  let(:basic_access_step2) { File.read(File.expand_path('BasicAccessStep2.do.html',support_files)) }
  let(:redirect) { File.read(File.expand_path('Redirect.do.html',support_files)) }
  let(:export_data1) { File.read(File.expand_path('ExportData1.do.html',support_files)) }
  let(:data) { File.read(File.expand_path('data.ofx',support_files)) }

  before do
    stub_request(:get, "https://ibank.barclays.co.uk/olb/y/BasicAccessStart.do").to_return(:status => 200, :body => basic_access_start, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, "https://ibank.barclays.co.uk/olb/y/BasicAccessStep1.do").to_return(:status => 200, :body => basic_access_step1, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, "https://ibank.barclays.co.uk/olb/y/BasicAccessStep2.do").to_return(:status => 200, :body => basic_access_step2, :headers => {'Content-Type' => 'text/html'})


    stub_request(:get, "https://ibank.barclays.co.uk/olb/y/Redirect.do?go=ExportData1.do%3Faction%3DExport%2BBank%2BStatement%7C%7CExport%2BData&Go=Go").to_return(:status => 200, :body => redirect, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData1.do').to_return(:status => 200, :body => export_data1, :headers => {'Content-Type' => 'text/html'})

    stub_request(:post, 'https://ibank.barclays.co.uk/olb/y/ExportData5.do').to_return(:status => 200, :body => data, :headers => {'Content-Type' => 'application/x-ofx'})

  end

  subject {Banker::Strategies::Barclays.new(:surname => 'Bloggs',
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
