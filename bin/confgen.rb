#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require_relative '../lib/common.rb'

# Parse options
options = {}
op = OptionParser.new do |opts|
  opts.banner = "Usage script.rb [options]"
  opts.on('-r ROUTER', '--router=ROUTER', String, 'Router hostname')  { |v| options[:router] = v }
  opts.on('-t TYPE', '--type=TYPE', String, 'Peer type')              { |v| options[:type] = v }
  opts.on('-a AS', '--as=AS', Integer, 'AS Number')                   { |v| options[:as] = v }
  opts.on('-A', '--all', 'Generate configuration for all peeers')     { |v| options[:all] = v }
  opts.on_tail("-h", "--help", "Display this screen")                 { puts op; exit }
end

# Exit on invalid or missing mandatory options
begin 
  op.parse!
  mandatory = []
  if options[:all].nil?
    mandatory = [:router, :type, :as]
  end
  missing = mandatory.select { |param| options[param].nil? }
  raise OptionParser::MissingArgument.new(missing.join(', ')) unless missing.empty?
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument, OptionParser::InvalidArgument
  puts $!.to_s
  puts op
  exit(-1)
end

# Read the YAML config file
if File.exist?(CONFIG_FILE)
  config = YAML.load(open(CONFIG_FILE).read)
  @ouras = config['config']['ouras']
else
  puts "Configuration file #{CONFIG_FILE} not found"
  exit(1)
end

# Generate config for a specific peer
if options[:all].nil?

  unless router = config['router']["#{options[:router]}"]
    puts "Unable to find ROUTER #{options[:router]} in the configuration file"
    exit
  end

  unless router["#{options[:type]}"]
    puts "Invalid type '#{options[:type]}', should be one of [ #{VALID_TYPES.join(', ')} ]"
    exit
  end

  unless as = router["#{options[:type]}"]["#{options[:as]}".to_i]
    puts "Unable to find AS#{options[:as]} in the configuration file for router #{options[:router]}"
    exit
  end

  @asn = "#{options[:as]}".to_i

  # Print header
  puts "# #{as['name']}"

  # local preference
  if as['ipv4'] and !as['ipv4']['local-preference']
    as['ipv4']['local-preference'] = get_local_preference_by_type(options[:type])
  end
  if as['ipv6'] and !as['ipv6']['local-preference']
    as['ipv6']['local-preference'] = get_local_preference_by_type(options[:type])
  end

  # Render the ERB template
  template = router['model']
  puts render_erb("#{template}", as)

else
# Generate config for all peers

  # Iterate through the routers
  config['router'].each { |router, rdata|

    # Iterate through the types 
    rdata.each { |type, data|

      # Skip invalid types
      next unless VALID_TYPES.include?(type)

      puts "## #{type.upcase}"

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
  
        # Print header
        puts "# #{v['name']} @ #{router}"

        # Render the ERB template
        template = rdata['model']
        puts render_erb("#{template}", v)
      }
    }
  }
end
