# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class ShowUserResponseTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_parse
    xml = parse_xml('tc_show_user_response.xml')
    r = ShowUserResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.user.*
    user = r.user
    assert_not_nil user
    assert_equal 'timeline-staff', user.nickname
    assert_equal 'http://stage.timeline.nifty.com/people/show/1', user.link
    assert_equal 'timeline staffです。', user.introduction
    assert_equal 'http://stage.timeline.nifty.com/portal/show_user_profile_image/1', user.image_url
  end

  def test_400
    xml = parse_xml('tc_show_user_response_400.xml')
    r = ShowUserResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 400, r.status.code
    assert_equal '対象のユーザが見つかりません', r.status.message
    assert_equal 'ja', r.status.language

    # response.user.*
    user = r.user
    assert_nil user
  end
end
