# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Snapshot do
  context '#attributes' do
    let(:snapshot) { Sherlock::Models::Snapshot.new }

    it 'should have many processes' do
      snapshot.should respond_to(:processes)
      snapshot.should respond_to(:processes=)
    end

    it 'should have many metrics' do
      snapshot.should respond_to(:metrics)
      snapshot.should respond_to(:metrics=)
    end
  end
end
