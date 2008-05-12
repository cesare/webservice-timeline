# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')
require 'date'
require 'test/unit'

class ShowTimelineResponseTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_parse
    xml = parse_xml('tc_show_timeline_response.xml')
    r = ShowTimelineResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.timeline
    tl = r.timeline
    assert_not_nil tl
    assert_instance_of Timeline, tl

    assert_equal 12345, tl.id
    assert_equal 'Test TimeLine', tl.title
    assert_equal 'http://timeline.nifty.com/some/timeline/url', tl.link
    assert_equal 'テスト。', tl.description
    assert_equal 'test-owner', tl.owner
    assert_equal 'test-vaxis', tl.label_for_vaxis
    assert_equal 'true', tl.commentable
    assert_equal 1, tl.open_level
    assert_equal 'test-readable', tl.opened_for
    assert_equal 0, tl.lock_level
    assert_equal 'test-writable', tl.locked_for
    assert_equal 987, tl.articles_count
    assert_equal 'recent', tl.initial_position
    assert_equal 'ten_years', tl.time_scale

    assert_instance_of DateTime, tl.updated_at
    assert_instance_of DateTime, tl.created_at
    assert_equal '2007-07-24T12:34:56+09:00', tl.updated_at.to_s
    assert_equal '2007-01-02T01:02:03+09:00', tl.created_at.to_s

    assert_equal 123, tl.score
    assert_equal 234, tl.point
    assert_equal 7654, tl.page_views
    assert_equal 'テスト', tl.category
  end

  def test_400
    xml = parse_xml('tc_show_timeline_response_400.xml')
    r = ShowTimelineResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 400, r.status.code
    assert_equal 'タイムラインが存在しないかプライベートモードのタイムラインが指定されています。', r.status.message
    assert_equal 'ja', r.status.language

    # response.timeline
    tl = r.timeline
    assert_nil tl
  end
end
