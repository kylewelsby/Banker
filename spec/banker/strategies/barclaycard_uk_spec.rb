require 'spec_helper'

describe Banker::Strategies::BarclaycardUK do
  let(:support_files) {File.expand_path('../../../support/barclaycard_uk/',__FILE__)}

  let(:initialLogon) {File.read(File.expand_path('initialLogon.do.html',support_files))}
  let(:validateMemorableWord) {File.read(File.expand_path('validateMemorableWord.do.html',support_files))}
  let(:cardSummary) {File.read(File.expand_path('cardSummary.do.html',support_files))}
  let(:data) {File.read(File.expand_path('data.ofx',support_files))}

  subject { Banker::Strategies::BarclaycardUK.new(:username => 'Bloggs',
                                                 :password => '123456',
                                                 :memorable_word => 'superduper')}

  before do
    stub_request(:get, 'https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do').to_return(:status => 200, :body => initialLogon, :headers => {'Content-Type' => 'text/html'})
    stub_request(:post, 'https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do').to_return(:status => 200, :body => validateMemorableWord, :headers => {'Content-Type' => 'text/html'})
    stub_request(:post, "https://bcol.barclaycard.co.uk/ecom/as2/validateMemorableWord.do").to_return(:status => 200, :body => cardSummary, :headers => {'Content-Type' => 'text/html'})
    stub_request(:get, "https://bcol.barclaycard.co.uk/ecom/as2/export.do?doAction=processRecentExportTransaction&type=OFX_2_0_2&statementDate=&sortBy=transactionDate&sortType=Dsc").to_return(:status => 200, :body => data, :headers => {'Content-Type' => 'application/x-ofx'})
  end

  describe '.new' do

    it{ subject.username.should eql 'Bloggs' }
    it{ subject.password.should eql '123456' }
    it{ subject.memorable_word.should eql 'superduper' }
    it{ subject.balance.should eql -82044 }

    it "should authenticate account" do
      subject

      WebMock.should have_requested(:get, 'https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do')
      WebMock.should have_requested(:post, 'https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do')
      WebMock.should have_requested(:post, 'https://bcol.barclaycard.co.uk/ecom/as2/validateMemorableWord.do').with(:body => "firstAnswer=E&secondAnswer=D")
      WebMock.should have_requested(:get, 'https://bcol.barclaycard.co.uk/ecom/as2/export.do?doAction=processRecentExportTransaction&type=OFX_2_0_2&statementDate=&sortBy=transactionDate&sortType=Dsc')

    end
  end
end
