# pedalog.rb
#
# Copyright (c) 2011 Dan Haughey (http://www.powwow-pedal-power.org.uk)
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
require 'ffi'

module Pedalog

  # Error codes
  PEDALOG_OK                              = 0
  PEDALOG_ERROR_UNKNOWN                   = 1
  PEDALOG_ERROR_NO_DEVICE_FOUND           = 2
  PEDALOG_ERROR_FAILED_TO_OPEN            = 3
  PEDALOG_ERROR_BAD_RESPONSE              = 4
  PEDALOG_ERROR_DEVICE_BUSY               = 5
  PEDALOG_ERROR_OUT_OF_MEMORY             = 6

  class Device
    attr_accessor :serial

    # Finds all the connected Pedalog devices, and returns an array of Device instances to describe them.
    def self.find_all
      max_devices = Interface::pedalog_get_max_devices

      device = FFI::MemoryPointer.new(Interface::PedalogDevice, max_devices, false)
      devices = max_devices.times.collect do |i|
        Interface::PedalogDevice.new(device + i * Interface::PedalogDevice.size)
      end

      device_count = Interface::pedalog_find_devices(device)

      result = device_count.times.collect do |i|
        devices[i].to_native
      end

      device.free

      result
    end

    # Gets a string describing an error code.
    def self.get_error_message(error)
      max_error_message = Interface::pedalog_get_max_error_message

      ptr = FFI::MemoryPointer.new(:char, max_error_message, false)

      Interface::pedalog_get_error_message(error, ptr)

      message = ptr.read_string

      ptr.free
      message
    end

    # Returns a Data instance with this device's current values, or nil if the device has been disconnected.
    # If nil is returned, Device.find_all should be called again to update the list of connected devices.
    def read_data
      device = Interface::PedalogDevice.new
      device.from_native(self)

      data = Interface::PedalogData.new

      result = Interface::pedalog_read_data(device, data)

      return nil if result == PEDALOG_ERROR_NO_DEVICE_FOUND
      throw Device.get_error_message(result) unless result == PEDALOG_OK

      data.to_native
    end
  end

  # A class to hold the data returned from a Pedalog device.
  class Data
    attr_accessor :voltage
    attr_accessor :current
    attr_accessor :power
    attr_accessor :energy
    attr_accessor :max_power
    attr_accessor :avg_power
    attr_accessor :time

    # Creates a string listing the data in an easily-readable format.
    def readable_string
      "voltage: %f, current: %f, power: %f, energy: %f, max_power: %f, avg_power: %f, time: %d\n" % [ voltage, current, power, energy, max_power, avg_power, time ]
    end
  end

  # Module containing methods that directly interface with libpedalog
  module Interface
    extend FFI::Library

    class PedalogDevice < FFI::Struct
      layout :serial, :int

      def to_native
        device = Device.new

        device.serial = self[:serial]

        device
      end

      def from_native(device)
        self[:serial] = device.serial
      end
    end

    class PedalogData < FFI::Struct
      layout :voltage, :double,
        :current, :double,
        :power, :double,
        :energy, :double,
        :max_power, :double,
        :avg_power, :double,
        :time, :int

      def to_native
        data = Data.new

        data.voltage = self[:voltage]
        data.current = self[:current]
        data.power = self[:power]
        data.energy = self[:energy]
        data.max_power = self[:max_power]
        data.avg_power = self[:avg_power]
        data.time = self[:time]

        data
      end
    end

    ffi_lib 'libpedalog'

    attach_function :pedalog_init, [ ], :int
    attach_function :pedalog_get_max_devices, [ ], :int
    attach_function :pedalog_get_max_error_message, [ ], :int
    attach_function :pedalog_find_devices, [ :pointer ], :int
    attach_function :pedalog_read_data, [ :pointer, :pointer ], :int
    attach_function :pedalog_get_error_message, [ :int, :pointer ], :void
  end
end

Pedalog::Interface::pedalog_init
