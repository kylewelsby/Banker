require 'spec_helper'

describe Banker::Barclays do

  LOGIN_URL = "https://bank.barclays.co.uk/olb/auth/LoginLink.action"
  EXPORT_URL = "https://bank.barclays.co.uk/olb/balances/ExportDataStep1.action"

  let(:support_files) {File.expand_path('../../support/barclays/',__FILE__)}
  let(:mechanize) {mock('mechanize') }
  let(:form) {mock('form')}
  let(:button) {mock('button')}
  let(:check) {mock('check')}
  let(:ofx) {
    f = File.open(File.expand_path('data.ofx', support_files), 'r:iso-8859-1')
    OFX(f.read)
  }
  let(:args) { { surname: 'Doe',
                 membership_number: '2010827349273',
                 passcode: '82736',
                 memorable_word: 'testing' } }

  subject { Banker::Barclays }

  describe 'Respond To' do
    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:download!)
      subject.any_instance.stub(:delivery)
      subject.any_instance.stub(:parse_ofx)
    end

    it { subject.new(args).should respond_to(:accounts) }
    it { subject.new(args).should respond_to(:ofx) }
  end

  describe 'Parameters' do
    before do
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:download!)
      subject.any_instance.stub(:delivery)
      subject.any_instance.stub(:parse_ofx)
    end

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
      subject.any_instance.stub(:download!)
      subject.any_instance.stub(:delivery)
      subject.any_instance.stub(:parse_ofx)
    end

    it "should Call params Method" do
      subject.any_instance.should_receive(:params)
      Banker::Barclays.new({})
    end

    it "should Call authenticate! Method" do
      subject.any_instance.should_receive(:authenticate!)
      Banker::Barclays.new({})
    end

    it "should Call download_account_data! Method" do
      subject.any_instance.should_receive(:download!)
      Banker::Barclays.new({})
    end
  end

  describe "#authenticate!" do
    before do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      Mechanize.any_instance.stub(get: mechanize)
      mechanize.stub(form_with: form.as_null_object)
      subject.any_instance.stub(:OFX).and_return(ofx)
      subject.any_instance.stub(:get_letter).and_return('s')
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

      form.should_receive(:buttons).exactly(5).times.and_return([button])
      mechanize.should_receive(:submit).exactly(5).times.with(form, button).
        and_return(mechanize.as_null_object)

      subject.new(args)
    end

    it 'should find the form element' do
      mechanize.should_receive(:form_with).with( action: 'LoginStep1i.action' ).
        and_return(form.as_null_object)

      subject.new(args)
    end

    it "should check passcode radio button" do
      form.should_receive(:radiobuttons).and_return(check)
      check.should_receive(:first).and_return(check)
      check.should_receive(:check).and_return(check)

      subject.new(args)
    end

    it "should submit" do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)

      form.should_receive(:buttons).exactly(5).times.and_return([button])
      mechanize.should_receive(:submit).exactly(5).times.with(form, button).
        and_return(mechanize.as_null_object)

      subject.new(args)
    end

    it 'should find the form element' do
      mechanize.should_receive(:form_with).with( action: 'LoginStep2.action' ).
        and_return(form.as_null_object)

      subject.new(args)
    end

    it "should fill in the form" do
      form.should_receive(:[]=).with('passcode', '82736')
      form.should_receive(:[]=).with("firstMemorableCharacter", "s")
      form.should_receive(:[]=).with("secondMemorableCharacter", "s")

      subject.new(args)
    end
  end

  describe '#download!' do
    before do
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:delivery)
      subject.any_instance.stub(:OFX).and_return(ofx)
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      Mechanize.any_instance.stub(get: mechanize)
      mechanize.stub(form_with: form.as_null_object)
    end

    it 'should call to EXPORT_URL' do
      mechanize.should_receive(:get).with(EXPORT_URL).
        and_return(mechanize.as_null_object)

      subject.new(args)
    end

    it 'should find the form element' do
      form_url = "/olb/balances/ExportDataStep1.action"
      mechanize.should_receive(:form_with).with( action: form_url ).
        and_return(form.as_null_object)

      subject.new(args)
    end

    it "should fill in the form" do
      form.should_receive(:[]=).with('reqSoftwarePkgCode', '6')
      form.should_receive(:[]=).with('productIdentifier', 'All')

      subject.new(args)
    end

    it 'should find the other form element' do
      form_url = "/olb/balances/ExportDataStep2All.action"
      mechanize.should_receive(:form_with).with( action: form_url ).
        and_return(form.as_null_object)

      subject.new(args)
    end

    it 'should parse ofx body' do
      subject.any_instance.should_receive(:OFX).and_return(ofx)

      subject.new(args)
    end
  end

  describe '#get_data' do
    let(:obj) { subject.new(args).accounts.first }

    before do
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:download!).and_return(ofx)
      subject.any_instance.stub(:ofx).and_return(ofx)
    end

    it { obj.uid.should == '077db20dce9425514828c5104b10df51' }
    it { obj.name.should == 'Barclays 1111' }
    it { obj.amount.should == 410010 }
    it { obj.currency.should == 'GBP' }
  end

end
