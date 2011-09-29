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

guard 'rspec', :version => 2, :cli => '--color --format nested --fail-fast', :all_on_start => true, :all_after_pass => true do

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
  watch(%r{^Gemfile\.lock$})                      { 'spec' }

end
