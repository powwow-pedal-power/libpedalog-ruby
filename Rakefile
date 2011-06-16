# Rakefile
#
# Copyright (c) 2011 Dan Haughey
#
# This file is part of libpedalog-ruby.
#
# libpedalog-ruby is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# libpedalog-ruby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with libpedalog-ruby.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = "pedalog"
  s.version       = "0.1.3"
  s.author        = "Dan Haughey"
  s.email         = "http://www.powwow-pedal-power.org.uk"
  s.summary       = "Ruby wrapper to the libpedalog library"
  s.description   = "This is a simple tool for reading data from Pedalog devices. It relies on the libpedalog library to do the actual
communication with the device: https://github.com/greenlynx/libpedalog

The Pedalog is a device made by Renewable Energy Innovations (http://www.re-innovation.co.uk).
It has been specially designed to monitor the power and energy generated by pedal powered electricity generators."
  s.homepage      = "https://github.com/greenlynx/libpedalog"
  s.files         = FileList['lib/*.rb'].to_a
  s.require_path  = "lib"
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
  puts "generated latest version"
end
