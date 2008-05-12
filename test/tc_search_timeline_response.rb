# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class SearchTimelineResponseTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_parse
    xml = parse_xml('tc_search_timeline_response.xml')
    r = SearchTimelineResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.summary.*
    s = r.summary
    assert_not_nil s
    assert_equal 123, s.total
    assert_equal 3, s.page
    assert_equal 15, s.page_count

    # response.timelines
    timelines = r.timelines
    assert_not_nil timelines
    assert_equal 2, timelines.size

    # response.timelines[0].*
    tl = timelines[0]
    assert_instance_of Timeline, tl
    assert_equal 987, tl.id
    assert_equal '１件目', tl.title

    # response.timelines[1].*
    tl = timelines[1]
    assert_instance_of Timeline, tl
    assert_equal 654, tl.id
    assert_equal '２件目', tl.title

  end

  def test_empty
    xml = parse_xml('tc_search_timeline_response_empty.xml')
    r = SearchTimelineResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.status.*
    s = r.summary
    assert_not_nil s
    assert_equal 0, s.total
    assert_equal 1, s.page
    assert_equal 1, s.page_count

    # response.timelines
    tl = r.timelines
    assert_not_nil tl
    assert_equal 0, tl.size
  end

  def test_400
    xml = parse_xml('tc_search_timeline_response_400.xml')
    r = SearchTimelineResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 400, r.status.code
    assert_equal 'APIのパラメータが不正です。', r.status.message
    assert_equal 'ja', r.status.language

    # response.status
    s = r.summary
    assert_nil s

    # response.timelines
    tl = r.timelines
    assert_nil tl
  end
end
