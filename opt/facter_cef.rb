## basic config start

var_cached_facts_file = ENV['ProgramData'] + '/PuppetLabs/facter/facts.d/facter_cef.yaml'

var_expensive_facts_regex = [
  'network_.*',
  'interfaces',
  'macaddress_.*',
  'netmask_.*',
  'ipaddress6_.*',
  'mtu_.*',
  'ipaddress_.*',
  'ipaddress',
  'ipaddress6',
  'netmask',
  'macaddress'
]

## basic config end

## advanced config start

var_facter_cmd = 'facter --no-external-dir --puppet --yaml --timing'

## advanced config end

## processing start
require 'yaml'
require 'open3'
require 'tempfile'

var_stdin, var_stdout, var_stderr = Open3.popen3(var_facter_cmd)

var_timing_data = Array.new
var_facter_data = String.new
var_cache = Hash.new

# ugly loop to split timing and facter yaml data into separate variables
var_datatype_yaml_flag = false

var_stdout.each do |var_line|
  if var_datatype_yaml_flag == true
    var_facter_data  += var_line
  else
    if var_line != "--- \n"
      var_timing_data.push(var_line)
    else
      var_datatype_yaml_flag = true
      var_facter_data  += var_line
    end
  end
end

# the rest does get loaded up as valid yaml!
var_facter_data = YAML.load(var_facter_data)

# in the timing data, look for matches of the expensive facts
var_timing_data.each do |var_line|
  var_expensive_facts_regex.each do |var_regex|
    if var_match = Regexp.new('(' + var_regex + '): ').match(var_line)
      if var_facter_data[var_match[1]]
        # if the fact is found in the yaml data as well, remember the value
        var_cache[var_match[1]] = var_facter_data[var_match[1]]
      else
        # if not, assign it a non null value so that facter doesn't try and look it up.
        # will think it has a value.
        var_cache[var_match[1]] = 'UNKNOWN'
      end
    end
  end
end

var_file_handle = Tempfile.new('facter_cef_')

var_file_handle.write(var_cache.to_yaml)
var_file_handle.close

# atomic write
File.rename(var_file_handle.path, var_cached_facts_file)

## processing end
