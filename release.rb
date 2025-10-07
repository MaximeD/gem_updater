#!/usr/bin/env ruby
# frozen_string_literal: true

# Purpose of this script is to update the version and changelog
# and run bundle install to update the Gemfile.lock
#
# It is used to release a new version of the gem.
#
require 'fileutils'
require 'date'

# Read current version from lib/gem_updater/version.rb
version_file = 'lib/gem_updater/version.rb'
current_version = nil

File.open(version_file, 'r') do |file|
  file.each_line do |line|
    m = line.match(/^\s*VERSION\s*=\s*['"]([^'\"]+)['\"]/)
    if m
      current_version = m[1]
      break
    end
  end
end

puts "Current version: #{current_version}"
print 'Enter new version: '
new_version = gets.chomp.strip

if new_version.empty?
  puts 'Error: Version cannot be empty'
  exit 1
end

# Update version file
version_content = File.read(version_file)
updated_version_content = version_content.gsub(
  /^\s*VERSION\s*=\s*['"][^'\"]+['\"]/,
  "  VERSION = '#{new_version}'"
)

File.write(version_file, updated_version_content)

# Update changelog
changelog_file = 'CHANGELOG.md'
changelog_content = File.read(changelog_file)

# Regex to find the master (unreleased) section and its content
master_section_regex = /# master \(unreleased\)\n+(.*?)(?=^# |\z)/m

if changelog_content =~ master_section_regex
  unreleased_content = Regexp.last_match(1).rstrip
  today = Date.today.strftime('%B %d, %Y')
  version_header = "# v#{new_version} (#{today})"
  # Remove the old master section and its content
  changelog_wo_master = changelog_content.sub(master_section_regex, '')
  # Build new changelog
  new_changelog = "# master (unreleased)\n\n#{unless unreleased_content.empty?
                                                "#{version_header}\n\n#{unreleased_content}\n\n"
                                              end}#{changelog_wo_master.lstrip}"
  File.write(changelog_file, new_changelog)
end

# Run bundler to update Gemfile.lock
puts "\nRunning 'bundle install' to update Gemfile.lock..."
system('bundle install')

puts "\n✅ Updated version to #{new_version}"
puts "Don't forget to:"
puts '1. Commit, push and merge the changes'
puts '2. Tag the release'
