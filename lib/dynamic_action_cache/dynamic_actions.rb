module ActionController
  module Caching
    module DynamicActions

      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
          base.class_eval do
            attr_accessor :rendered_dynamic_action_cache, :uncached_partial_enabled
          end
      end

      module InstanceMethods
        # figure out the key the same way the caches action does    
        # Not yet supported
        def cache_for_action(key, &block)
          unless read_fragment(key)
            yield
          end
        end    
      end

      module ClassMethods
        # Declares that +actions+ should be cached.
        # See ActionController::Caching::Actions for details.
        def caches_dynamic_action(*actions)
          return unless cache_configured?

          options = actions.extract_options!
          filter_options = { :only => actions, :if => options.delete(:if), :unless => options.delete(:unless) }
          
          cache_filter = DynamicActionCacheFilter.new(:layout => options.delete(:layout), :cache_path => options.delete(:cache_path), :store_options => options)
          around_filter(cache_filter, filter_options)
        end
      end

      protected
        def expire_action(options = {})
          return unless cache_configured?

          if options[:action].is_a?(Array)
            options[:action].dup.each do |action|
              expire_fragment(ActionController::Caching::Actions::ActionCachePath.path_for(self, options.merge({ :action => action }), false))
            end
          else
            expire_fragment(ActionController::Caching::Actions::ActionCachePath.path_for(self, options, false))
          end
        end

      class DynamicActionCacheFilter < ActionController::Caching::Actions::ActionCacheFilter
        def initialize(options, &block)
          @options = options
        end

        def before(controller)
          cache_path = ActionController::Caching::Actions::ActionCachePath.new(controller, path_options_for(controller, @options.slice(:cache_path)))
          # if the cache exists then re-render it
          if cache = controller.read_fragment(cache_path.path, @options[:store_options])
            controller.rendered_dynamic_action_cache = true
            set_content_type!(controller, cache_path.extension)
            options = { :inline => cache }
            options.merge!(:layout => true) if cache_layout?
            controller.__send__(:render, options)
            false
          else                                   
            # otherwise let it through
            controller.action_cache_path = cache_path
            controller.uncached_partial_enabled = true

          end                         
          
          # we want to always let the request through to the controller so it can excute key actions
          # alternatively you would have to do it all in before filters
        end

        def after(controller)
          return if controller.rendered_dynamic_action_cache || !caching_allowed(controller)
          
          # write the content to the cache
          action_content = cache_layout? ? content_for_layout(controller) : controller.response.body
          controller.write_fragment(controller.action_cache_path.path, action_content, @options[:store_options])
          
          # re-render the content
          options = { :inline => action_content }
          options.merge!(:layout => true) if cache_layout?
          controller.__send__(:erase_render_results)
          controller.__send__(:render, options)
          
        end

        private
          # provided for rails 2.1 support

          def cache_layout?
            @options[:layout] == false
          end

      end

    end
  end
end
