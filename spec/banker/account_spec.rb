require 'spec_helper'

describe Banker::Account do
  let(:attr){{
    name:'',
    uid:'',
    amount:'',
    limit:''
  }}
  subject {Banker::Account}

  it {subject.new(attr).should respond_to(:name)}
  it {subject.new(attr).should respond_to(:uid)}
  it {subject.new(attr).should respond_to(:amount)}
  it {subject.new(attr).should respond_to(:limit)}

  it "validates presence of name" do
    expect{
      subject.new
    }.to raise_error(ArgumentError, "missing attribute `name`")
  end
  it "validates presence of uid" do
    expect{
      subject.new(name:'')
    }.to raise_error(ArgumentError, "missing attribute `uid`")
  end
  it "validates presence of amount" do
    expect{
      subject.new(name:'',uid:'')
    }.to raise_error(ArgumentError, "missing attribute `amount`")
  end
end
