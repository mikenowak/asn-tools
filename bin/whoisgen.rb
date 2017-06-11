#!/usr/bin/env ruby

require 'yaml'
require_relative '../lib/common.rb'

# Read the YAML config file
if File.exist?(CONFIG_FILE)
  config = YAML.load(open(CONFIG_FILE).read)
  @ouras = config['config']['ouras']
else
  puts "Configuration file #{CONFIG_FILE} not found"
  exit(1)
end

# Hashes for storing communities, upstreams, downstreams, and peers
community = {}

config['router'].each { |router, rdata|
  rdata.each { |type, data|

    # Skip invalid types
    next unless VALID_TYPES.include?(type)

    puts "remarks:\t+====================================================================="
    puts "remarks:\t| #{type.capitalize}"
    puts "remarks:\t+====================================================================="
    puts "remarks:"

    # Iterate through all peers of a type
    data.each { |k, v|
      @asn = k

      # local preference
      if v['ipv4'] and !v['ipv4']['local-preference']
        v['ipv4']['local-preference'] = get_local_preference_by_type(type)
      end
      if v['ipv6'] and !v['ipv6']['local-preference']
        v['ipv6']['local-preference'] = get_local_preference_by_type(type)
      end

      # Render the ERB template
      template = "whois"
      puts render_erb("#{template}", v)

      # Add BGP Communities to a hash
      community.merge!({v['community']=>{:name=>v['name'], :asn=>@asn, :type=>type}})

    }
  }
}

unless community.nil?
  community.sort.to_h
  puts "remarks:\t+====================================================================="
  puts "remarks:\t| BGP Communities (set upon ingress)"
  puts "remarks:\t+====================================================================="
  puts "remarks:"

  VALID_TYPES.each { |t|
    c = community.select { |k, v| v[:type] == "#{t}" }
    klass = c.keys.first.to_s.gsub(/...$/, 'xxx')
 
    unless klass == ""
      puts "remarks:\t#{klass} #{t.capitalize}"
      c.each { |k, v|
        puts "remarks:\t#{k} #{v[:name]} (AS#{v[:asn]})"
      }
    end
  }
end
puts "remarks:"
