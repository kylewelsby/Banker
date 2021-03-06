require 'spec_helper'

describe Banker::Base do
  describe "#params" do
    it "raises Invalid Parameters if any defined parameters are missing" do
      expect{
        subject.keys = ['test']
        subject.params({})
      }.to raise_error(Banker::Error::InvalidParams,
                       "missing parameters `test` ")
    end
  end

  describe "#get" do
    let(:mechanize) {mock('mechanize')}
    let(:logger) {mock('logger')}
    it "should assign agent with a new instance of Mechanize" do
      Mechanize.should_receive(:new).and_return(mechanize)
      Logger.should_receive(:new).and_return(logger)

      agent = stub 'agent'
      http = stub 'http'
      mechanize.should_receive(:user_agent=).with("Mozilla/5.0 (Banker)")
      mechanize.should_receive(:log=).with(logger)
      mechanize.should_receive(:force_default_encoding=).with("utf8")
      mechanize.should_receive(:get).with("http://google.com")
      mechanize.should_receive(:agent).and_return(agent)
      agent.should_receive(:http).and_return(http)
      http.should_receive(:ssl_version=).with(:SSLv3)

      subject.get("http://google.com")
    end
  end

  describe "#get_letter" do
    it "gets the index 1st character from a string" do
      subject.get_letter("bank",1).should eql "b"
    end
  end
end
