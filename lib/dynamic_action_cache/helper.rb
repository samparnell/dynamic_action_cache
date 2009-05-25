module DynamicActionCache
  module Helper              
    # Currently this only supports the partial name being provide in options.
    def render_uncached(options)
      raise "Blocks not supported" if block_given?
      
      if controller.uncached_partial_enabled
        "<%= render :partial => \"#{options[:partial]}\" %>"
      else
        render options
      end
    end
  end
end
