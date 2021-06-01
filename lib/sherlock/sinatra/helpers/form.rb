# encoding: utf-8

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
