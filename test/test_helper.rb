require 'rubygems'
gem 'activesupport', '~> 3.0.0'

require 'test/unit'
require 'active_support/test_case'

require File.expand_path('../../lib/markup', __FILE__)

class ActiveSupport::TestCase
  cattr_accessor :fixture_path

  self.fixture_path = File.expand_path('../fixtures', __FILE__)

  def fixture(name, type = :txt)
    File.read("#{fixture_path}/#{name}.#{type}")
  end
end
