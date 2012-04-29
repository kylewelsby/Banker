require 'spec_helper'

describe Banker::LloydsTSBUK do
  TEST_FIELD = {
    username: 'frmLogin:strCustomerLogin_userID',
    password: 'frmLogin:strCustomerLogin_pwd',
    memorable_word: [
      'frmentermemorableinformation1:strEnterMemorableInformation_memInfo1',
      'frmentermemorableinformation1:strEnterMemorableInformation_memInfo2',
      'frmentermemorableinformation1:strEnterMemorableInformation_memInfo3'
    ]
  }

  let(:mechanize) {mock('mechanize').as_null_object}
  let(:form) {mock('form')}
  let(:button) {mock('button')}
  let(:args) { { username: 'Doe',
                 password: '82736',
                 memorable_word: 'testing' } }

  subject { Banker::LloydsTSBUK }

  before do
    subject.any_instance.stub(:params)
    subject.any_instance.stub(:authenticate!)
    subject.any_instance.stub(:delivery!)
  end

  it {subject.new.should respond_to(:accounts)}

  describe "Parameters" do
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

  describe "Method Calls" do
    it "should Call params Method" do
      subject.any_instance.should_receive(:params)
      subject.new
    end

    it "should Call authenticate! Method" do
      subject.any_instance.should_receive(:authenticate!)
      subject.new
    end

    it "should Call delivery! Method" do
      subject.any_instance.should_receive(:delivery!)
      subject.new
    end
  end

  describe "private" do
    before do
      Mechanize.stub(:new).and_return(mechanize)
      Mechanize.any_instance.stub(get: mechanize)
    end

    describe "#authenticate!" do
      before do
        subject.any_instance.unstub(:authenticate!)
        mechanize.stub(form_with: form.as_null_object)
        mechanize.stub(:submit).and_return(mechanize)
        subject.any_instance.stub(:get_letter).and_return('s')
      end

      it "should call to LOGIN_URL" do
        mechanize.should_receive(:get).
          with("https://online.lloydstsb.co.uk/personal/logon/login.jsp").
          and_return(mechanize.as_null_object)

        subject.new(args)
      end

      it 'should find the form element' do
        mechanize.should_receive(:form_with).with( action: '/personal/primarylogin' ).
          and_return(form.as_null_object)

        subject.new(args)
      end

      it "should fill in the form" do
        form.should_receive(:[]=).with(TEST_FIELD[:username], 'Doe')
        form.should_receive(:[]=).with(TEST_FIELD[:password], '82736')

        subject.new(args)
      end

      it "should submit" do
        Mechanize.stub(:new).and_return(mechanize.as_null_object)

        form.should_receive(:buttons).exactly(2).times.and_return([button])
        mechanize.should_receive(:submit).exactly(2).times.with(form, button).
          and_return(mechanize.as_null_object)

        subject.new(args)
      end

      it 'should find the form element' do
        mechanize.should_receive(:form_with).
          with( action: '/personal/a/logon/entermemorableinformation.jsp' ).
          and_return(form)

        subject.new(args)
      end

      it "should fill in the form" do
        subject.any_instance.unstub(:get_letter)
        subject.any_instance.stub(:memorable_required).with(mechanize).and_return([1,2,3])

        form.should_receive(:[]=).with(TEST_FIELD[:memorable_word][0], "&nbsp;t")
        form.should_receive(:[]=).with(TEST_FIELD[:memorable_word][1], "&nbsp;e")
        form.should_receive(:[]=).with(TEST_FIELD[:memorable_word][2], "&nbsp;s")

        subject.new(args)
      end
    end

    describe '#delivery!' do
      let(:obj) { subject.new(args).accounts.first }

      before do
        subject.any_instance.unstub(:delivery!)
        subject.any_instance.stub(:name).and_return(['A', 'B', 'C'])
        subject.any_instance.stub(:identifier).and_return([['A'], ['B'], ['C']])
        subject.any_instance.stub(:balance).and_return([1.00, 2.00, 3.00])
        subject.any_instance.stub(:limit).and_return([1.00, 2.00, 3.00])
      end

      it 'should call to EXPORT_URL' do
        mechanize.should_receive(:get).
          with('https://secure2.lloydstsb.co.uk/personal/a/account_overview_personal/').
          and_return(mechanize.as_null_object)

        subject.new(args)
      end

      it { obj.name.should == "A" }
      it { obj.uid.should == "9f0728995cad501bad95aa513f07b4e9" }
      it { obj.amount.should == 1.0 }
      it { obj.limit.should == 1.0 }
      it { obj.currency.should == 'GBP' }
    end
  end
end
