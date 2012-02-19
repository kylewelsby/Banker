# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Banker::Stratagies::LloydsTSBUK do
  let(:login) { File.read(File.expand_path('../../../support/lloyds_tsb_uk/login.jsp.html',__FILE__)) }
  let(:login_post) { File.read(File.expand_path('../../../support/lloyds_tsb_uk/login_post.txt',__FILE__)) }
  let(:memorable) { File.read(File.expand_path('../../../support/lloyds_tsb_uk/entermemorableinformation.jsp.html',__FILE__)) }
  let(:memorable_post) { File.read(File.expand_path('../../../support/lloyds_tsb_uk/memorable_post.txt',__FILE__)) }
  # let(:welcome) { File.read(File.expand_path('../../../support/lloyds_tsb_uk/interstitialpage.jsp.html',__FILE__)) }
  # let(:accounts) { File.read(File.expand_path('../../../support/lloyds_tsb_uk/account_overview_personal.html',__FILE__)) }

  before do
    stub_request(:get, "https://online.lloydstsb.co.uk/personal/logon/login.jsp").
      to_return(:status => 200, :body => login, :headers => { "Content-Type" => "text/html" })
    stub_request(:post, "https://online.lloydstsb.co.uk/personal/primarylogin").
      to_return(:status => 200, :body => login_post, :headers => { "Content-Type" => "application/x-www-form-urlencoded" })
    stub_request(:get, "https://secure2.lloydstsb.co.uk/personal/a/logon/entermemorableinformation.jsp").
      to_return(:status => 200, :body => memorable, :headers => { "Content-Type" => "text/html" })
    stub_request(:post, "https://secure2.lloydstsb.co.uk/personal/a/logon/entermemorableinformation.jsp").
      to_return(:status => 200, :body => memorable_post, :headers => { "Content-Type" => "text/html" })
    # stub_request(:post, "https://secure2.lloydstsb.co.uk/personal/a/logon/interstitialpage.jsp").
    #   to_return(:status => 200, :body => welcome, :headers => { "Content-Type" => "text/html" })
  end

  subject { Banker::Stratagies::LloydsTSBUK.new(:username => 'Joe', 
                                                :password => 'password',
                                                :memorable_word => 'superduper') }

  describe '.new' do
    it { subject.username.should eql 'Joe' }
    it { subject.password.should eql 'password' }
    it { subject.balance.should eql 0 }

    it "should authenticate account login" do
      subject
      WebMock.should have_requested(:get, 'https://online.lloydstsb.co.uk/personal/logon/login.jsp')
      WebMock.should have_requested(:post, 'https://online.lloydstsb.co.uk/personal/primarylogin')
    end

    it "should authenticate account memorable word" do
      subject
      WebMock.should have_requested(:get, 'https://secure2.lloydstsb.co.uk/personal/a/logon/entermemorableinformation.jsp')
      WebMock.should have_requested(:post, 'https://secure2.lloydstsb.co.uk/personal/a/logon/entermemorableinformation.jsp')
    end
  end

end
