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

      # Simple number formatting helpers for Sinatra.
      module Numbers

        # Convert a byte value to MB.
        #
        # @param [ Integer ] bytes The byte value to convert to MB.
        # 
        # @return [ Integer ] The MB value.
        def bytes_to_mb(bytes)
          (bytes.to_f / 1024 / 1024).round(2)
        end

        # Convert a seconds-value to "HOURS:MINUTES:SECONDS" format.
        #
        # @param [ Integer ] time The number of seconds to convert to a
        #   string.
        #
        # @return [ String ] The seconds in "HOUR:MINUTE:SECONDS" format.
        def seconds_as_time(time)

          seconds = (time % 60).to_i
          minutes = ((time / 60) % 60).to_i
          hours = ((time / 3600)).to_i

          "#{hours}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"

        end

      end

    end
  end
end
