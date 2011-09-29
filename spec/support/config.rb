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

# Stub out the config_directory method in the Sherlock configuration module to
# make it read configuration files from spec/assets/config/ instead of the
# default config/ directory.
def stub_config_directory
  test_config_dir = asset_file_path('config')
  Sherlock::Config.stub!(:config_directory).and_return(test_config_dir)
end
