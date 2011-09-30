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

module Sherlock #:nodoc
  module Sinatra #:nodoc
    module Helpers #:nodoc

      # Partial template implementation for Sinatra.
      #
      # This code is copied from Sam Elliotts partials.rb, located at
      # https://gist.github.com/119874.
      module Partials

        # Render a partial template.
        def partial(template, *args)

          template_array = template.to_s.split('/')
          template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
          options = args.last.is_a?(Hash) ? args.pop : {}
          options.merge!(:layout => false)
          if collection = options.delete(:collection) then
            collection.inject([]) do |buffer, member|
              buffer << haml(:"#{template}", options.merge(:layout =>
                  false, :locals => {template_array[-1].to_sym => member}))
            end.join("\n")
          else
            haml(:"#{template}", options)
          end
        end
        
      end

    end
  end
end
