require 'spec_helper'

describe Banker::Strategies::CreditExpertUK do
  let(:support_files) {File.expand_path('../../../support/credit_expert_uk/',__FILE__)}

  let(:mcclogin) {
    File.read(
      File.expand_path('MCCLogin.aspx.html', support_files)
    )
  }

  let(:mcclogin_memorable_word) {
    File.read(
      File.expand_path('MCCLoginMemorableWord.aspx.html', support_files)
    )
  }

  let(:mcc) {
    File.read(
      File.expand_path('MCC.aspx.html', support_files)
    )
  }


  subject {Banker::Strategies::CreditExpertUK.new(:username => "Bloggs",
                                               :password => "123456",
                                               :memorable_word => "superduper")}

  before do
    stub_request(
      :get,
      'https://www.creditexpert.co.uk/MCCLogin.aspx'
    ).to_return(
      :status => 200,
      :body => mcclogin,
      :headers => {
        'Content-Type' => 'text/html'
      }
    )

    stub_request(
      :post,
      'https://www.creditexpert.co.uk/MCCLogin.aspx'
    ).to_return(
      :status => 200,
      :body => mcclogin_memorable_word,
      :headers => {
        'Content-Type' => 'text/html'
      }
    )

    stub_request(
      :post,
      %r{https://www.creditexpert.co.uk/MCCLoginMemorableWord.aspx}
    ).to_return(
      :status => 200,
      :body => mcc,
      :headers => {
        'Content-Type' => 'text/html'
      }

    )
  end

  describe '.new' do
    it{ subject.username.should eql 'Bloggs' }
    it{ subject.password.should eql '123456' }
    it{ subject.memorable_word.should eql 'superduper' }
    it{ subject.score.should eql 648 }

    it "should authenticate account" do
      subject

      WebMock.should have_requested(:get, 'https://www.creditexpert.co.uk/MCCLogin.aspx')
      WebMock.should have_requested(:post, 'https://www.creditexpert.co.uk/MCCLogin.aspx')
    end
  end
end
