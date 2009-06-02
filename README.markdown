DynamicActionCache
==================

An action caching mechanism that allows partials to be rendered dynamically. 

This works just like <code>caches\_action</code> but provides an alternative partial include helper. 
Including a partial using <code>render\_uncached</code> will always render the partial content even when
the rest of the action is cached.

-------

script/plugin:

<pre>
script/plugin install git://github.com/samparnell/dynamic_action_cache.git 
</pre>


