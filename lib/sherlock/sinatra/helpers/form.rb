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

      # Simple form helper for Sinatra.
      module Form

        # Render a option element for a select list.
        #
        # @param [ String ] value The value of the option.
        # @param [ String ] label The label of the option.
        # @param [ String ] current_value The current value of the select
        #   field, used to determine if the option element should be
        #   selected or not.
        #
        # @return [ String ] The markup for a <option/> element.
        def option_element(value, label, current_value)
          tag = "<option value=\"#{escape_html(value)}\""
          tag += " selected=\"selected\"" if current_value.to_s == value.to_s
          tag += ">#{escape_html(label)}</option>"
          tag
        end

      end

    end
  end
end
