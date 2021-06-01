# encoding: utf-8

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
