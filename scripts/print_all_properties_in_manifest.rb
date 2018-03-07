#!/usr/bin/env ruby
require 'yaml'
require 'pp'
class ::Hash
    def deep_merge(second)
        return self if second.nil?
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end

def key_finder(tree, current_key=[], acum_keys=[])
  case tree
    when Hash
      new_keys = []
      tree.each { |k,v|
        new_keys += key_finder(v, current_key+[k], acum_keys)
      }
      return acum_keys + new_keys
    when Array
      new_keys = []
      tree.each_with_index { |v,i|
        new_keys += key_finder(v, current_key+[i.to_s], acum_keys)
      }
      return acum_keys + new_keys

    else
      return acum_keys + [current_key.join('.')]
    end
end

manifest_file=ARGV[0]
manifest = YAML.load_file(manifest_file)

all_properties = manifest["properties"] || {}
manifest["instance_groups"].each { |instance_group|
  all_properties = all_properties.deep_merge(instance_group["properties"])
  instance_group["jobs"].each { |job|
    all_properties = all_properties.deep_merge(job["properties"])
  }
}

puts key_finder(all_properties).sort

