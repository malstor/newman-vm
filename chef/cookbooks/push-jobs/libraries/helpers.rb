#
# Cookbook Name:: push-jobs
# Library:: helpers
#
# Author:: Joshua Timberman <joshua@chef.io>
# Author:: Charles Johnson <charles@chef.io>
# Author:: Mark Anderson <mark@chef.io>
# Copyright 2013-2015 Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'
require 'chef/config'

# Helper functions for Push Jobs cookbook
module PushJobsHelper # rubocop:disable Metrics/ModuleLength
  def self.package_file(url = 'http://www.opscode.com/chef/install.sh')
    uri = ::URI.parse(::URI.unescape(url))
    package_file = File.basename(uri.path)
    package_file
  end

  def self.config_path
    ::File.join(config_dir, 'push-jobs-client.rb')
  end

  def self.config_dir
    Chef::Config.platform_specific_path('/etc/chef')
  end

  def self.names_by_version(version, platform)
    family =
      if version =~ /^1\.[0-2]/
        :family_1_0
      elsif version =~ /^1\.3/
        :family_1_3
      elsif version =~ /^2\.0\.0-alpha/
        :family_2_alpha
      else
        fail "No info for version '#{version}'"
      end
    NAMING_DATA[family][platform]
  end

  def self.windows_package_name(node, version)
    if node['push_jobs']['package_name']
      node['push_jobs']['package_name']
    else
      names_by_version(version, :windows)[:package_name] % { v: version }
    end
  end

  def self.windows_service_name(node, version)
    if node['push_jobs']['service_name']
      node['push_jobs']['service_name']
    else
      names_by_version(version, :windows)[:service_name]
    end
  end

  def self.linux_install_path(node, version = nil)
    version ||= find_installed_version(node)
    node['push_jobs']['install_path'] || names_by_version(version, :linux)[:install_path]
  end

  def self.linux_exec_name(node, version = nil)
    version ||= find_installed_version(node)
    node['push_jobs']['exec_name'] || names_by_version(version, :linux)[:exec_name]
  end

  # This may be worth incorporating in to chef_ingredient
  def self.version_from_manifest(path)
    json_path = File.join(path, 'version-manifest.json')
    txt_path = File.join(path, 'version-manifest.txt')
    version = if File.exist?(json_path)
                JSON.parse(IO.read(json_path))['build_version']
              elsif File.exist?(txt_path)
                File.readlines(txt_path, 100).first.split(' ')[1]
              end
    version
  end

  def self.find_installed_version(node, url = nil)
    url ||= node['push_jobs']['package_url']
    version = parse_version(node, url)
    return version if version

    # heuristic to deduce version if we can't find it out some other
    # fashion. This may happen if we're using chef ingredient to find
    # latest, which doesn't provide a method to determine what it
    # picked.
    names = %w(/opt/push-jobs-client /opt/opscode-push-jobs-client)

    possible_versions = names.map { |d| version_from_manifest(d) }

    version = possible_versions.find { |v| v }
    return version if version

    return '1.0.0' if File.exist?('/opt/opscode-push-jobs-client')
  end

  def self.parse_version(node, url)
    return node['push_jobs']['package_version'] if node['push_jobs']['package_version']
    Regexp.last_match(1) if url =~ /[\-_](\d+\.\d+\.\d+(\-alpha)?)[\-_]/
  end

  NAMING_DATA ||=
    { family_1_0:
        {
          windows: {
            package_name: 'Opscode Push Jobs Client Installer for Windows v%{v}',
            service_name: 'pushy-client'
          },
          linux: {
            install_path: '/opt/opscode-push-jobs-client',
            exec_name: 'pushy-client'
          }
        },
      family_1_3:
        {
          windows: {
            package_name: 'Push Jobs Client v%{v}',
            service_name: 'push-jobs-client' },
          linux: {
            install_path: '/opt/push-jobs-client',
            exec_name: 'pushy-client'
          }
        },
      family_2_alpha:
        {
          windows: {
            package_name: 'Push Jobs Client v%{v}',
            service_name: 'push-jobs-client' },
          linux: {
            install_path: '/opt/push-jobs-client',
            exec_name: 'pushy-client'
          }
        }
    }
end
