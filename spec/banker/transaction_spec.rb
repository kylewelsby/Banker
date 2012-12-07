require 'spec_helper'

describe Banker::Transaction do
  let(:attr) {{
    :amount => 1000,
    :transacted_at => Time.now
  }}
  subject {Banker::Transaction}

  it { expect(subject.new(attr)).to respond_to(:description) }
  it { expect(subject.new(attr)).to respond_to(:amount) }
  it { expect(subject.new(attr)).to respond_to(:transacted_at) }
  it { expect(subject.new(attr)).to respond_to(:uid) }
  it { expect(subject.new(attr)).to respond_to(:type) }

  it "validates presence of amount" do
    expect{ subject.new }.to raise_error(Banker::Error::InvalidParams, %r{amount})
  end

  it "validates presence of transacted_at" do
    expect{ subject.new }.to raise_error(Banker::Error::InvalidParams, %r{transacted_at})
  end
end
