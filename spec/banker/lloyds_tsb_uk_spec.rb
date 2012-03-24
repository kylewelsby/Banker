# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'mechanize'

describe Banker::LloydsTSBUK do
  let(:support_files) {File.expand_path('../../support/lloyds_tsb_uk/',__FILE__)}
  let(:login) { File.read(File.expand_path('login.jsp.html', support_files)) }
  let(:memorable) { File.read(File.expand_path('entermemorableinformation.jsp.html', support_files)) }
  let(:accounts) { File.read(File.expand_path('account_overview_personal.html', support_files)) }
  # let(:welcome) { File.read(File.expand_path('interstitialpage.jsp.html', support_files)) }

  before do
    stub_request(:get, "https://online.lloydstsb.co.uk/personal/logon/login.jsp").
      to_return(:status => 200, :body => login, :headers => { "Content-Type" => "text/html" })
    stub_request(:post, "https://online.lloydstsb.co.uk/personal/primarylogin").
      to_return(:status => 200, :body => memorable, :headers => { "Content-Type" => "text/html" })
    stub_request(:post, "https://online.lloydstsb.co.uk/personal/a/logon/entermemorableinformation.jsp").
      to_return(:status => 200, :body => accounts, :headers => { "Content-Type" => "text/html" })
  end

  subject { Banker::LloydsTSBUK.new(:username => 'Joe',
                                                :password => 'password',
                                                :memorable_word => 'superduper') }

  describe '.new' do
    it { subject.username.should eql 'Joe' }
    it { subject.password.should eql 'password' }
    it { subject.balance.should be_a_kind_of(Array) }

    it "should authenticate account login" do
      subject
      WebMock.should have_requested(:get, 'https://online.lloydstsb.co.uk/personal/logon/login.jsp')
      WebMock.should have_requested(:post, 'https://online.lloydstsb.co.uk/personal/primarylogin')
      WebMock.should have_requested(:post, 'https://online.lloydstsb.co.uk/personal/a/logon/entermemorableinformation.jsp')
    end
  end

  describe '.get_memorable_word_letter' do
    it { should respond_to(:get_memorable_word_letter) }
    it 'should return requested letter' do
      @memorable_word = 'Test'
      subject.get_memorable_word_letter('4').should eql 'e'
    end
  end

  describe '.cleaner' do
    it { should respond_to(:cleaner) }
    it 'should remove unwanted characters' do
      subject.cleaner("Test123Test").should eql '123'
    end
  end

end
