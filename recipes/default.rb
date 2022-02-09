# Cookbook Name:: base
# Recipe:: package
#
# Author:: Victor Penso
#
# Copyright:: 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'erb'

resource_list = %w(
  group
  user
  directory
  file
  remote_file
  link
  template
  apt_repository
  apt_update
  apt_package
  yum_repository
  yum_package
  package
  git
  subversion
  execute
  bash
  script
  service
  systemd_unit
  route
  mount
)

if not node['base']['resources'].empty?
  resource_list += node['base']['resources']
end

resource_list.each do |resource|

  next unless node.has_key? resource
  next if node[resource].empty?

  # Ignore platform dependent resources
  case resource
  when 'apt_repository'
  when 'apt_update'
  when 'apt_package'
    next unless node['platform'] == 'debian'
  when 'yum_repository'
  when 'yum_package'
    next unless node['platform'] == 'centos'
  end

  # Convenience for package deployment
  if %w(apt_package yum_package package).include? resource
    if node[resource].is_a? Array
      package node[resource]
      next
    end
  end

  node[resource].each do |name,conf|

    case conf['template_fields']
     
    when String
      template_fields = [conf['template_fields']] 
    when Chef::Node::ImmutableArray
      template_fields = conf['template_fields']
    else
      template_fields = []
    end

    public_send(resource, name) do

      conf.each do |key,value|
        value=ERB.new(value).result_with_hash(node:node) if template_fields.include?key
      
        case key

        when 'content'
          if resource.eql? 'file'

            # Disable the header comment by attribute 
            banner = if not node[resource][name].has_key? 'banner' 
                       true
                     else
                       node[resource][name]['banner']
                     end

            # Add a banner to indicate that the written file is
            # managed by Chef
            if banner 
              value = "
                #
                # DO NOT CHANGE THIS FILE MANUALLY!
                #
                # This file is managed by the Chef configuration management system
                #
              #{value}
              "
            end

          end

          value = value.gsub(/^ */,'')
          value = value.split("\n")
          value = value[1..-1] if value[0] =~ /^$/
          value = value.join("\n") << "\n"
          send(key,value)
        
        when 'template','not_if','only_if'
          send(key, *value)

        when 'notifies','subscribes'
          # nested arrays indicate multiple notifies/subscribes
          if value[0].kind_of? Array
            # loop over the notifies/subscribes
            value.each do |sub_value|
              # and send them individually
              send(key, *sub_value)
            end
          # a single notifies/subscribes
          else
            send(key, *value)
          end

        # Ignore the following keys...
        when 'banner','template_fields'
          next

        # Pass all attributes as resource properties by default
        else
          send(key,value)
        end

      end

    end

  end

end
