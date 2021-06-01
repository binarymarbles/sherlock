# encoding: utf-8

# Read the contents of an asset file found in spec/assets/.
#
# @return [ String ] The contents of the file.
def read_asset_file(filename)
  File.open(asset_file_path(filename), 'r') { |f| f.read }
end

# Figure out the full path to a asset file.
#
# @example Find the full path for an asset file.
#   asset_file_path('agent-data/valid.json')
#
# @param [ String ] filename The relative path to the file.
#
# @return [ String ] The full path to the file.
def asset_file_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'assets', filename))
end
