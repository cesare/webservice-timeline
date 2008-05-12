# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class RequestTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def setup
    @config = Config.new do |c|
    end
  end

  def test_initialize
    r = Request.new(@config)
    assert_equal @config, r.instance_eval { @config }
  end

  def test_create_key_value_pair
    r = Request.new(@config)
    r.instance_eval do
      def __test(key, val)
        create_key_value_pair(key, val)
      end
    end

    assert_equal 'key=value', r.__test(:key, 'value')
    assert_equal 'key=test%20value', r.__test(:key, 'test value')
    assert_equal 'key=%E3%83%86%E3%82%B9%E3%83%88', r.__test(:key, 'テスト')

    assert_equal 'key=value', r.__test(:key, :value)
    assert_equal 'key=2007-08-09T12%3A34%3A56%2B09%3A00', r.__test(:key, DateTime.parse('2007-08-09T12:34:56+09:00'))
  end

  def test_create_query
    r = Request.new(@config)
    r.instance_eval do
      def __test(params)
        create_query(params)
      end
    end

    results = r.__test({})
    assert_equal 0, results.size

    results = r.__test(:key => 'value')
    assert_equal 1, results.size
    assert_equal 'key=value', results[0]

    results = r.__test(:key => 'テスト')
    assert_equal 1, results.size
    assert_equal 'key=%E3%83%86%E3%82%B9%E3%83%88', results[0]

    results = r.__test(:test1 => 'test value',
                       :test2 => 'value of test2',
                       :key => 'value'
                       ).sort!
    assert_equal 3, results.size
    assert_equal 'key=value', results[0]
    assert_equal 'test1=test%20value', results[1]
    assert_equal 'test2=value%20of%20test2', results[2]

    results = r.__test(:key => ['test1', 'test2']).sort!
    assert_equal 2, results.size
    assert_equal 'key=test1', results[0]
    assert_equal 'key=test2', results[1]

    results = r.__test(:key => ['テスト1', 'テスト2']).sort!
    assert_equal 2, results.size
    assert_equal 'key=%E3%83%86%E3%82%B9%E3%83%881', results[0]
    assert_equal 'key=%E3%83%86%E3%82%B9%E3%83%882', results[1]

    results = r.__test(:list => ['test1', 'test2'], :key => 'value').sort!
    assert_equal 3, results.size
    assert_equal 'key=value', results[0]
    assert_equal 'list=test1', results[1]
    assert_equal 'list=test2', results[2]

  end

end
