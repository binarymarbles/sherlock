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

class Sherlock::Controllers::Watson < Sherlock::Sinatra::BaseController

  # Handle ParserErrors from the snapshot parser and present them properly to
  # any connecting agent.
  error Sherlock::Errors::ParserError do
    status(422) # Unprocessable entity.
    env['sinatra.error'].message
  end
  
  post '/snapshot' do
    parser = Sherlock::SnapshotParser.new(request.body.read.to_s)
    parser.persist!
    parser.snapshot.id.to_s
  end

end
