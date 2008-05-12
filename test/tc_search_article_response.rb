# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class SearchArticleResponseTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_parse
    xml = parse_xml('tc_search_article_response.xml')
    r = SearchArticleResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.summary.*
    s = r.summary
    assert_not_nil s
    assert_equal 1234, s.total
    assert_equal 1, s.page
    assert_equal 123, s.page_count

    # response.articles
    articles = r.articles
    assert_not_nil articles
    assert_equal 2, articles.size

    # response.articles[0].*
    a = articles[0]
    assert_instance_of Article, a
    assert_equal 123, a.id
    assert_equal '１件目', a.title

    # response.articles[1].*
    a = articles[1]
    assert_instance_of Article, a
    assert_equal 456, a.id
    assert_equal '２件目', a.title
  end

  def test_empty
    xml = parse_xml('tc_search_article_response_empty.xml')
    r = SearchArticleResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.summary.*
    summary = r.summary
    assert_not_nil summary
    assert_equal 0, summary.total
    assert_equal 1, summary.page
    assert_equal 1, summary.page_count

    # response.articles
    articles = r.articles
    assert_not_nil articles
    assert articles.empty?
  end

  def test_400
    xml = parse_xml('tc_search_article_response_400.xml')
    r = SearchArticleResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 400, r.status.code
    assert_equal '検索方法に timeline_id, phrase, time_spec のどれかを指定してください', r.status.message
    assert_equal 'ja', r.status.language

    # response.summary
    summary = r.summary
    assert_nil summary

    # response.articles
    articles = r.articles
    assert_nil articles
  end
end
