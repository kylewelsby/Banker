# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Banker::CapitalOneUK do
  let(:mechanize) {mock('mechanize')}
  let(:node) {mock('node')}
  let(:form) {mock('form')}
  let(:button) {mock('button')}

  subject { Banker::CapitalOneUK}

  before do
    subject.any_instance.stub(:params)
    subject.any_instance.stub(:authenticate!)
    subject.any_instance.stub(:get_data)
  end

  it {subject.new().should respond_to(:accounts)}

  context "Parameters" do
    before do
      subject.any_instance.unstub(:params)
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:get_data)
    end

    it "raises InvalidParams when email is missing" do
      expect{
        subject.new
      }.to raise_error(Banker::Error::InvalidParams,
                       "missing parameters `username` `password` ")
    end

    it "raises InvalidParams when password is missing" do
      expect{
        subject.new(email: 'test@test.com')
      }.to raise_error(Banker::Error::InvalidParams)
    end

    it 'accepts email and password' do
      expect{
        subject.new(email: 'test@test.com', password: 'superduper')
      }.to raise_error(Banker::Error::InvalidParams)
    end
  end

  context "calls" do
    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:get_data)
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
    describe "#authenticate!" do
      before do
        Mechanize.stub(:new).and_return(mechanize.as_null_object)
        mechanize.stub(form_with: form.as_null_object)

        mechanize.stub(:at).and_return(node.as_null_object)
        subject.any_instance.unstub(:authenticate!)
        subject.any_instance.stub(:get_letter)
        subject.any_instance.stub(:get_data)
      end

      it "finds by form name" do
        mechanize.should_receive(:form_with).with(
          name: "logonForm"
        ).and_return(form)
        subject.new
      end

      it "fills in form inputs" do
        mechanize.should_receive(:at).with("#sign_in_box .password").
          and_return(node)
        node.should_receive(:content).
          and_return("1st 2nd 3rd")
        subject.any_instance.unstub(:get_letter)

        form.should_receive(:[]=).with("username", "joebloggs")
        form.should_receive(:[]=).with("password.randomCharacter0", "s")
        form.should_receive(:[]=).with("password.randomCharacter1", "u")
        form.should_receive(:[]=).with("password.randomCharacter2", "p")
        subject.new(username: 'joebloggs', password: 'superduper')
      end

      it "submits form" do
        form.should_receive(:buttons).and_return([button])
        mechanize.should_receive(:submit).with(form, button)
        subject.new
      end
    end

    describe "#get_data" do
      before do
        Mechanize.stub(:new).and_return(mechanize.as_null_object)
        mechanize.stub(form_with: form.as_null_object)
        mechanize.stub(:at).and_return(node.as_null_object)
        #node.stub(content: "£100")
        subject.any_instance.stub(:get_letter)

        subject.any_instance.unstub(:authenticate!)
        subject.any_instance.unstub(:get_data)
      end

      it "finds account balance" do
        mechanize.should_receive(:at).
          with("table[summary='account summary'] tr:nth-child(1) td.normalText:nth-child(2)").
          and_return(node)
        node.should_receive(:content).
          at_least(:once).
          and_return("£900.10")
        subject.new
      end
      it "finds account limit" do
        mechanize.should_receive(:at).
          with("table[summary='account summary'] tr:nth-child(2) td.normalText:nth-child(2)").
          and_return(node)
        node.should_receive(:content).
          at_least(:once).
          and_return("£950.50")
        subject.new
      end
    end
  end
end
