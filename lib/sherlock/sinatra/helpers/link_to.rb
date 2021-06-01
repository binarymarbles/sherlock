# encoding: utf-8

module Sherlock #:nodoc
  module Sinatra #:nodoc
    module Helpers #:nodoc

      # Simple link_to helper for Sinatra.
      module LinkTo

        # Render a link.
        def link_to(label, url)
          "<a href=\"#{escape_html(url)}\">#{escape_html(label)}</a>"
        end

      end

    end
  end
end
