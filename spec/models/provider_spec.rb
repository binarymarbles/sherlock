# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Provider do

  context '#validations' do
    let(:provider) { Sherlock::Models::Provider.new(:id => 'test-provider', :name => 'Test Provider') }

    it 'should be valid' do
      provider.should be_valid
    end

    it 'should validate presence of id' do
      provider.id = nil
      provider.should_not be_valid
    end

    it 'should validate presence of name' do
      provider.name = nil
      provider.should_not be_valid
    end
  end

end
