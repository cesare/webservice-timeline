# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class ShowArticleResponseTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_parse
    xml = parse_xml('tc_show_article_response.xml')
    r = ShowArticleResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.article.*
    a = r.article
    assert_not_nil a
    assert_instance_of Article, a

    assert_equal 12345, a.id
    assert_equal 'テスト中', a.title
    assert_equal 'テストです。', a.description
    assert_equal 'test-user', a.owner

    assert_instance_of DateTime, a.start_time
    assert_instance_of DateTime, a.end_time
    assert_equal '2007-07-24T12:34:56+09:00', a.start_time.to_s
    assert_equal '2007-07-25T01:02:03+09:00', a.end_time.to_s

    assert_equal 'test-grade', a.grade
    assert_equal 'http://timeline.nifty.com/some/image/url', a.image_url
    assert_equal 'http://timeline.nifty.com/url/for/an/article', a.link

    assert_instance_of DateTime, a.updated_at
    assert_instance_of DateTime, a.created_at
    assert_equal '2007-07-25T02:03:04+09:00', a.updated_at.to_s
    assert_equal '2007-07-25T03:04:05+09:00', a.created_at.to_s

    # response.article.related_urls[]
    urls = a.related_urls
    assert_not_nil urls
    assert_equal 2, urls.size
    assert_equal 'http://www.example.com/related', urls[0]
    assert_equal 'http://foo.nifty.com/nowhere', urls[1]
  end

  def test_400
    xml = parse_xml('tc_show_article_response_400.xml')
    r = ShowArticleResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 400, r.status.code
    assert_equal '【できごと】が存在しないかプライベートモードのタイムラインの【できごと】が指定されています。', r.status.message
    assert_equal 'ja', r.status.language

    # response.article.*
    a = r.article
    assert_nil a
  end
end
