# encoding: utf-8

# Stub out the config_directory method in the Sherlock configuration module to
# make it read configuration files from spec/assets/config/ instead of the
# default config/ directory.
def stub_config_directory
  test_config_dir = asset_file_path('config')
  Sherlock::Config.stub!(:config_directory).and_return(test_config_dir)
end
