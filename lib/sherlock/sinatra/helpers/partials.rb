# encoding: utf-8

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
