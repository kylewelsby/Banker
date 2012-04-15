require 'spec_helper'

describe Banker::Barclays do

  LOGIN_URL = "https://bank.barclays.co.uk/olb/auth/LoginLink.action"

  let(:mechanize) {mock('mechanize') }
  let(:form) {mock('form')}
  let(:button) {mock('button')}
  let(:check) {mock('check')}
  let(:args) { { surname: 'Doe',
                 membership_number: '2010827349273',
                 passcode: '82736',
                 memorable_word: 'testing' } }

  subject { Banker::Barclays }

  describe 'Respond To' do
    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
    end

    it { subject.new(args).should respond_to(:accounts) }
  end

  describe 'Parameters' do
    before { subject.any_instance.stub(:authenticate!) }

    context 'Valid Params' do
      it { expect{ subject.new(args) }.to_not raise_error }
    end

    context 'Invalid Params' do
      keys = %w(surname membership_number passcode memorable_word)

      keys.each do |key|
        it "should raise InvalidParams when #{key} is not passed" do
          msg = "missing parameters `#{key}` "
          expect{ subject.new(args.delete_if { |k,v| k if k == key.to_sym })}.
            to raise_error(Banker::Error::InvalidParams, msg)
        end
      end
    end
  end

  describe 'Method Calls' do
    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
    end

    it "should Call params Method" do
      subject.any_instance.should_receive(:params)
      Banker::Barclays.new({})
    end

    it "should Call authenticate! Method" do
      subject.any_instance.should_receive(:authenticate!)
      Banker::Barclays.new({})
    end
  end

  describe "#stage_one" do
    before do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      Mechanize.any_instance.stub(get: mechanize)
      mechanize.stub(form_with: form.as_null_object)
    end

    it 'should call to LOGIN_URL' do
      mechanize.should_receive(:get).with(LOGIN_URL).
        and_return(mechanize.as_null_object)

      subject.new(args)
    end

    it 'should find the form element' do
      mechanize.should_receive(:form_with).with( action: 'LoginLink.action' ).
        and_return(form.as_null_object)

      subject.new(args)
    end

    it "should fill in the form" do
      form.should_receive(:[]=).with('surname', 'Doe')
      form.should_receive(:[]=).with('membershipNumber', '2010827349273')

      subject.new(args)
    end

    it "should submit" do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)

      form.should_receive(:buttons).twice.and_return([button])
      mechanize.should_receive(:submit).twice.with(form, button).
        and_return(mechanize.as_null_object)

      subject.new(args)
    end
  end

  describe "#stage_two()" do
    before do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      Mechanize.any_instance.stub(get: mechanize)
      mechanize.stub(form_with: form.as_null_object)
    end

    it 'should find the form element' do
      mechanize.should_receive(:form_with).with( action: 'LoginStep1i.action' ).
        and_return(form.as_null_object)

      subject.new(args)
    end

    it "should check passcode radio button" do
      form.should_receive(:checkbox_with).and_return(check)
      check.should_receive(:check).and_return(check)

      subject.new(args)
    end

    it "should submit" do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)

      form.should_receive(:buttons).twice.and_return([button])
      mechanize.should_receive(:submit).twice.with(form, button).
        and_return(mechanize.as_null_object)

      subject.new(args)
    end
  end

  describe "#stage_three()" do
    before do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      Mechanize.any_instance.stub(get: mechanize)
      mechanize.stub(form_with: form.as_null_object)
    end

    it 'should find the form element' do
      mechanize.should_receive(:form_with).with( action: 'LoginStep2.action' ).
        and_return(form.as_null_object)

      subject.new(args)
    end

    it "should fill in the form" do
      form.should_receive(:[]=).with('passcode', '82736')

      subject.new(args)
    end
  end

  describe Banker::Barclays::Account do
    let(:account_id) { 1 }
    let(:agent) { mechanize.as_null_object }

    before { Mechanize.any_instance.stub(get: mechanize) }

    subject { Banker::Barclays::Account.new(account_id, agent) }

    it { subject.should respond_to(:name) }
    it { subject.should respond_to(:amount) }
  end
end
