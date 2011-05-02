require 'rubygems'
require "bundler/setup"

require 'test/unit'
require 'active_support/test_case'
require 'active_support/core_ext/class'

require 'markup'

class ActiveSupport::TestCase
  cattr_accessor :fixture_path

  self.fixture_path = File.expand_path('../fixtures', __FILE__)

  def fixture(name, type = :txt)
    File.read("#{fixture_path}/#{name}.#{type}")
  end
end

