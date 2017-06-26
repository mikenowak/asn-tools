#!/usr/bin/env ruby
#
# Mike Nowak <https://www.github.com/mikenowak/>
#

require 'erb'

# Find the root directory
ROOT=File.join(File.dirname(__FILE__), '../')

# Default path to config file
CONFIG_FILE="#{ROOT}/conf/config.yaml"

# Valid peer types
VALID_TYPES = ['upstream', 'downstream', 'peering']

# render_erb returns a rendered ERB template
# the function takes two arguments, the template name, and the variable scope
def render_erb(template, scope = {})
  t = "#{ROOT}/templates/#{template}.erb"
  b = binding
  scope.each{ |key, value| b.local_variable_set(key.to_sym, value) }
  return ERB.new(File.read(t), nil, '-').result(b)
end

# get_local_preference_by_type returns a local-preference value based on peer type
def get_local_preference_by_type(type)
  case type
  when 'upstream'
    p = 100
  when 'downstream'
    p = 300
  when 'peering'
    p = 200
  end

  return p
end
