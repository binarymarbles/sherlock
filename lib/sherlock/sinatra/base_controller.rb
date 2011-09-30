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

    # Base class for all Sinatra controllers.
    class BaseController < ::Sinatra::Base

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
          haml(template_name, options.merge(:layout => '../layout'.to_sym))
      end

    end

  end
end
