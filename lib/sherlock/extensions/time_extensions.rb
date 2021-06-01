# encoding: utf-8

module TimeExtensions

  # Round the current time down to the nearest amount of seconds.
  # 
  # @param [ Integer ] seconds The number of seconds to round with.
  #
  # @return [ Time ] The new, rounded time value.
  def floor(seconds)
    Time.at((self.to_f / seconds).round * seconds)
  end

end

Time.send(:include, TimeExtensions)
