# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class ConfigTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_default
    client = WebService::TimeLine::API.new
    config = client.instance_eval { @config }
    assert_not_nil config
    assert_equal 'api.timeline.nifty.com', config.request_domain
    assert_equal '/api/v1/', config.request_path_base
    assert_equal 80, config.request_port
    assert config.open_timeout > 0
    assert config.read_timeout > 0
    assert_nil config.timeline_key
    assert_not_nil config.user_agent
  end

  def test_init_params
    client = WebService::TimeLine::API.new(
                                           :timeline_key => 'testkey',
                                           :domain => 'testdomain',
                                           :port => 8080,
                                           :open_timeout => 888,
                                           :read_timeout => 999
                                           )
    config = client.instance_eval { @config }
    assert_not_nil config
    assert_equal 'testdomain', config.request_domain
    assert_equal '/api/v1/', config.request_path_base
    assert_equal 8080, config.request_port
    assert_equal 888, config.open_timeout
    assert_equal 999, config.read_timeout
    assert_equal 'testkey', config.timeline_key
    assert_not_nil config.user_agent
  end

  def test_new_block
    client = WebService::TimeLine::API.new do |c|
      c.timeline_key = 'testblockkey'
      c.request_domain = 'testblockdomain'
      c.request_port = 8880
      c.open_timeout = 88
      c.read_timeout = 99
    end

    config = client.instance_eval { @config }
    assert_not_nil config
    assert_equal 'testblockdomain', config.request_domain
    assert_equal '/api/v1/', config.request_path_base
    assert_equal 8880, config.request_port
    assert_equal 88, config.open_timeout
    assert_equal 99, config.read_timeout
    assert_equal 'testblockkey', config.timeline_key
    assert_not_nil config.user_agent
  end
end
