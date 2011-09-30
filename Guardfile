# encoding: utf-8
# vim:ft=ruby

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

guard 'pow' do
  watch('.rvmrc')
  watch('Gemfile.lock')
  watch('config.ru')
  watch('app.rb')
  watch(%r{^lib/.*\.rb$})
  watch(%r{^app/.*\.rb$})
  watch(%w{^config/.*\.rb$})
end

guard 'compass', :configuration_file => 'spec/assets/compass-config.rb' do
  watch(%r{^app/stylesheets/.+\.scss$})
end

guard 'coffeescript', :input => 'app/javascripts', :output => 'public/javascripts'

guard 'rspec', :version => 2, :cli => '--color --format nested --fail-fast', :all_on_start => false, :all_after_pass => false do

  # Map any file under lib/sherlock to the matching spec under spec/
  watch(%r{^lib/sherlock/(.+)\.rb$})              { |m| "spec/#{m[1]}_spec.rb" }

  # Rerun the spec when any spec file changes.
  watch(%r{^spec/.+_spec\.rb$})

  # Rerun all tests when the spec helper changes.
  watch('spec/spec_helper.rb')                    { 'spec' }

  # Rerun all tests when a spec support file changes.
  watch(%r{^spec/support/.+\.rb$})                { 'spec' }

  # Rerun the snapshot parser spec when any agent data asset changes.
  watch(%r{^spec/assets/agent-data/.+\.json$})    { 'spec/snapshot_parser_spec.rb' }

  # Rerun the config spec when any configuration asset changes.
  watch(%r{^spec/assets/config/.+\.json$})        { 'spec/config_spec.rb' }

  # Rerun all tests when the Gemfile.lock file changes.
  watch('Gemfile.lock')                           { 'spec' }

  # Rerun request specs when any controller file changes.
  watch(%r{^app/controllers/(.+)\.rb$})           { |m| "spec/requests/#{m[1]}_spec.rb" }

  # Rerun all request tests when config.ru changes.
  watch('config.ru')                              { 'spec/requests' }

  # Rerun all request tests when app.rb changes.
  watch('app.rb')                                 { 'spec/requests' }

  # Rerun all request tests when any sinatra-file changes.
  watch(%r{^lib/sherlock/sinatra/})               { 'spec/requests' }

  # Rerun request tests when a view changes.
  watch(%r{^app/views/(.+)/})                     { |m| "spec/requests/#{m[1]}_spec.rb" }
  
end
