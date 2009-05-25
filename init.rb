$:.unshift File.dirname(__FILE__) + "/lib"
require 'dynamic_action_cache'
 
# Extend the action controller with caching methods
ActionController::Base.send(:include, ActionController::Caching::DynamicActions)
ActionController::Base.send(:include, ActionController::Caching::DynamicActions::InstanceMethods)
                                                   
# Provide dynamic cache helper
ActionController::Base.helper(DynamicActionCache::Helper)