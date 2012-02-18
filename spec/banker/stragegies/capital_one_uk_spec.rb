# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Banker::Stratagies::CapitalOneUK do
  let(:login) { File.read(File.expand_path('../../../support/capital_one_uk/Login.do.html',__FILE__)) }
  let(:transactions) { File.read(File.expand_path('../../../support/capital_one_uk/Transactions.do.html',__FILE__)) }
  let(:data) { File.read(File.expand_path('../../../support/capital_one_uk/data.csv',__FILE__)) }

  before do
    stub_request(:get, "https://www.capitaloneonline.co.uk/CapitalOne_Consumer/Login.do").to_return(:status => 200, :body => login, :headers => {'Content-Type' => 'text/html'})
    stub_request(:post, "https://www.capitaloneonline.co.uk/CapitalOne_Consumer/ProcessLogin.do").to_return(:status => 200, :body => transactions, :headers => {'Content-Type' => 'text/html'})
    stub_request(:post, "https://www.capitaloneonline.co.uk/CapitalOne_Consumer/DownLoadTransaction.do").to_return(:status => 200, :body => data, :headers => {'Content-Type' => 'text/csv; charset=utf-8'})
  end
  
  subject { Banker::Stratagies::CapitalOneUK.new(:username => 'Joe',
                                                :password => 'password') }

  describe '.new' do
    it { subject.username.should eql "Joe" }

    it { subject.password.should eql "password" }

    it { subject.balance.should eql 0 }

    it { subject.limit.should eql 95000 }

    it "should authenticate account" do
      subject

      WebMock.should have_requested(:get, 'https://www.capitaloneonline.co.uk/CapitalOne_Consumer/Login.do')
      WebMock.should have_requested(:post, 'https://www.capitaloneonline.co.uk/CapitalOne_Consumer/ProcessLogin.do')
      WebMock.should have_requested(:post, 'https://www.capitaloneonline.co.uk/CapitalOne_Consumer/DownLoadTransaction.do')
    end

    it "should return transactions" do
      subject.transactions.should be_a(CSV::Table)
      subject.transactions.first['Billing Amount'].should include "667.97"
    end
  end
end