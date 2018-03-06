#!/usr/bin/env ruby
require 'yaml'

class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end

class PropertyTree
  def initialize(tree)
    @tree = tree
  end

  def self.load_yaml(yaml_string)
    PropertyTree.new(YAML.safe_load(yaml_string))
  end

  def recursive_get(tree, key_array)
    return tree if key_array.empty?
    current_key, *next_keys = key_array

    next_level = case tree
                 when Hash
                   tree[current_key]
                 when Array
                   if current_key =~ /\A[-+]?\d+\z/ # If the key is an int, access by index
                     tree[current_key.to_i]
                   else # if not, search for a element with `name: current_key`
                     tree.select { |x| x.is_a?(Hash) && x['name'] == current_key }.first
                   end
                 end
    if not next_level.nil?
      recursive_get(next_level, next_keys)
    end
  end

  def get(key)
    key_array = key.split('.')
    self.recursive_get(@tree, key_array)
  end

  def [](key)
    self.get(key)
  end

  def delete(key)
    @tree.delete(key)
  end

  def tree()
    @tree
  end

end

RELEASES_DIR=ENV["RELEASES_DIR"] || "/tmp/releases/"
manifest_file=ARGV[0]

@spec_cache = {}
def load_spec(release, job)
  key = release+'/'+job

  if not @spec_cache.has_key? key
    spec_file = "#{RELEASES_DIR}/#{release}/jobs/#{job}/spec"
    if File.exists?(spec_file)
      @spec_cache[key] = YAML.load_file(spec_file)
    else
      STDERR.puts "Missing spec file of release #{release}: #{spec_file}"
    end
  end

  return @spec_cache[key]
end

def add_tree_value(key, value)
  keys = key.split('.')
  if keys.length == 1
    return { key => value }
  else
    return { keys[0] => add_tree_value(keys[1..-1].join('.'), value) }
  end
end

def get_properties_of_job(manifest, instance_group, release, job)
  spec = load_spec(release, job)
  properties = {}
  if spec != nil and spec["properties"] != nil
    spec["properties"].each {|k, v|
      # Merge the global properties and the instance_group ones
      properties_tree = PropertyTree.new(manifest["properties"].deep_merge(instance_group["properties"] || {}))
      if properties_tree[k] != nil
        properties = properties.deep_merge(add_tree_value(k, properties_tree[k]))
      end
    }
  end
  return properties
end

manifest = YAML.load_file(manifest_file)

manifest["instance_groups"].each do |instance_group|
  instance_group["jobs"].each do |job|
    next if job["properties"] != nil # Skip if the template
    job_properties = get_properties_of_job(manifest, instance_group, job["release"], job["name"])
    next if job_properties.empty?
    job["properties"] = job_properties
  end
end

manifest.delete("properties")
manifest["instance_groups"].each do |instance_group|
  instance_group.delete("properties")
end

puts manifest.to_yaml()
