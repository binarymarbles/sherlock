# encoding: utf-8

module Sherlock #:nodoc
  module Sinatra #:nodoc

    # Base class for all Sinatra controllers.
    class BaseController < ::Sinatra::Base

      helpers ::Sinatra::ContentFor
      helpers Sherlock::Sinatra::Helpers::Partials
      helpers Sherlock::Sinatra::Helpers::LinkTo
      helpers Sherlock::Sinatra::Helpers::Form
      helpers Sherlock::Sinatra::Helpers::Numbers

      # Set the view directory to be the app/views/<controller name>/ directory.
      set :views, Proc.new { File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'views', self.name.demodulize.underscore)) }

      protected

      # Render a template to the view.
      #
      # @param [ Symbol ] template_name The name of the template to render.
      # @param [ Hash ] options An optional hash of options to pass to the
      #   underlying rendering method.
      #
      # @return [ String ] The rendered template.
      def render_template(template_name, options = {})
          prepare_instance_variables
          haml(template_name, options.merge(:layout => '../layout'.to_sym))
      end

      # Prepare the instance variables that should be accessible by all views.
      def prepare_instance_variables
        @controller_name ||= self.class.name.demodulize.underscore
      end

      # Define the title of the page.
      #
      # @param [ String ] title The title of the page.
      def title(title)
        @title = title
      end

      # Expose an attribute to the view.
      #
      # @param [ Symbol ] key The key of the attribute to expose.
      # @param [ Object ] value The value of the attribute to expose.
      def expose(key, value)
        instance_variable_set("@#{key.to_s}", value)
      end

    end

  end
end
