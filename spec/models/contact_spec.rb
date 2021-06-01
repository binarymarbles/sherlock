# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Contact do

  context '#validations' do
    let(:contact) { Sherlock::Models::Contact.new(:name => 'Test Contact', :email => 'test@test.com') }

    it 'should be valid' do
      contact.should be_valid
    end

    it 'should validate presence of name' do
      contact.name = nil
      contact.should_not be_valid
    end

    it 'should validate presence of e-mail address' do
      contact.email = nil
      contact.should_not be_valid
    end
  end

end
