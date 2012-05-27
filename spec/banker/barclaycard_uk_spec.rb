require 'spec_helper'

describe Banker::BarclaycardUK do
  let(:support_files) {File.expand_path('../../support/barclaycard_uk/',__FILE__)}

  LOGIN_ENDPOINT = 'https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do'
  EXPORT_ENDPOINT = 'https://bcol.barclaycard.co.uk/ecom/as2/export.do?doAction=processRecentExportTransaction&type=OFX_2_0_2&statementDate=&sortBy=transactionDate&sortType=Dsc'

  let(:mechanize) {mock('mechanize').as_null_object}
  let(:node) {mock('node').as_null_object}
  let(:form) {mock('form').as_null_object}
  let(:button) {mock('button').as_null_object}
  let(:ofx) {
    f = File.open(File.expand_path('data.ofx',support_files), 'r:iso-8859-1')
    f.read
  }

  subject { Banker::BarclaycardUK }

  before do
    subject.any_instance.stub(:params)
    subject.any_instance.stub(:authenticate!)
    subject.any_instance.stub(:get_data)
  end

  it {subject.new.should respond_to(:accounts)}

  context "Parameters" do
    before do
      subject.any_instance.unstub(:params)
    end

    it "raises InvalidParams when username is missing" do
      expect{
        subject.new
      }.to raise_error(Banker::Error::InvalidParams,
                       "missing parameters `username` `password` `memorable_word` ")
    end

    it "raises InvalidParams when password is missing" do
      expect{
        subject.new(username: "joe")
      }.to raise_error(Banker::Error::InvalidParams,
                       "missing parameters `password` `memorable_word` ")
    end

    it "raises InvalidParams when memorable_word is missing" do
      expect{
        subject.new(username: "joe", password: "123456")
      }.to raise_error(Banker::Error::InvalidParams,
                       "missing parameters `memorable_word` ")

    end

    it "accepts username, password and memorable_word" do
      expect{

        subject.new(username: "joe", password: "123456",
                    memorable_word: "superduper")
      }.to_not raise_error
    end
  end

  context "calls" do
    it "calls params" do
      subject.any_instance.should_receive(:params)
      subject.new
    end
    it "calls authenticate!" do
      subject.any_instance.should_receive(:authenticate!)
      subject.new
    end
    it "calls get_data" do
      subject.any_instance.should_receive(:get_data)
      subject.new
    end
  end

  context "private" do
    before do
      Mechanize.stub(:new).and_return(mechanize)
      mechanize.stub(:get).and_return(mechanize)
      mechanize.stub(:form_with).and_return(form)
      mechanize.stub(:at).and_return(node)
      mechanize.stub(:submit).and_return(mechanize)
    end

    describe "#authenticate!" do
      before do
        subject.any_instance.unstub(:authenticate!)
        subject.any_instance.stub(:get_letter).and_return("A")
      end
      it "gets #{LOGIN_ENDPOINT}" do
        mechanize.should_receive(:get).
          with("https://bcol.barclaycard.co.uk/ecom/as2/initialLogon.do").
          and_return(mechanize)
        subject.new
      end
      it "finds by form action" do
        mechanize.should_receive(:form_with).
          with(action: "/ecom/as2/initialLogon.do").
          and_return(form)
        subject.new
      end
      it "fills in form inputs" do
        mechanize.should_receive(:at).
          with("label[for='lettera']").
          and_return(node)

        mechanize.should_receive(:at).
          with("label[for='letterb']").
          and_return(node)


        node.should_receive(:content).
          at_least(:twice).
          and_return("1")

        subject.any_instance.unstub(:get_letter)

        form.should_receive(:[]=).with("username", "joe")
        form.should_receive(:[]=).with("password", "123456")
        form.should_receive(:[]=).with("firstAnswer", "S")
        form.should_receive(:[]=).with("secondAnswer", "S")


        subject.new(username: "joe", password: "123456",
                    memorable_word: "superduper")
      end

      it "submits form" do
        form.should_receive(:buttons).
          twice.
          and_return([button])
        mechanize.should_receive(:submit).
          with(form,button)
        subject.new
      end

      it "parses html for account limit" do
        mechanize.should_receive(:at).
          with(".panelSummary .limit .figure").
          and_return(node)
        subject.new
      end

    end

    describe "#get_data" do
      before do
        subject.any_instance.unstub(:get_data)
        mechanize.stub(get: stub(body: ofx))
      end

      it "gets #{EXPORT_ENDPOINT}" do
         mechanize.should_receive(:get).
          with(EXPORT_ENDPOINT).
          and_return(stub(body: ofx))
        subject.new
      end
    end
  end
end
