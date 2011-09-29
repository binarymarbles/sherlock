# encoding: utf-8

# Copyright 2011 Binary Marbles.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
