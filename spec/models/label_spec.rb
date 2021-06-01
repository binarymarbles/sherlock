# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Label do
  context '#validations' do
    let(:label) { Sherlock::Models::Label.new(:node_id => 'test_node', :path => 'test.metric', :value => 'Test Label') }

    it 'should be valid' do
      label.should be_valid
    end

    it 'should validate presence of node_id' do
      label.node_id = nil
      label.should_not be_valid
    end

    it 'should validate presence of path' do
      label.path = nil
      label.should_not be_valid
    end

    it 'should validate presence of value' do
      label.value = nil
      label.should_not be_valid
    end
  end
end
