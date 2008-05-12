# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class ListCategoryResponseTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_parse
    xml = parse_xml('tc_list_category_response.xml')
    r = ListCategoryResponse.unmarshal(xml.root)

    # response.status.*
    assert_not_nil r.status
    assert_equal 200, r.status.code
    assert_equal 'OK', r.status.message
    assert_equal 'ja', r.status.language

    # response.categories.*
    categories = r.categories
    assert_not_nil categories
    assert_equal 7, categories.size

    # response.categories[0].*
    c = categories[0]
    assert_equal '時間・歴史', c.display_name
    assert_nil c.name

    # response.categories[0].sub_categories
    scs = c.sub_categories
    assert_not_nil scs
    assert_equal 4, scs.size

    # response.categories[0].sub_categories[0]
    sc = scs[0]
    assert_equal 'personal', sc.name
    assert_equal '自分史', sc.display_name
    assert_nil sc.sub_categories

    # response.categories[0].sub_categories[3]
    sc = scs[3]
    assert_equal 'event', sc.name
    assert_equal 'イベント', sc.display_name
    assert_nil sc.sub_categories


    # response.categories[6].*
    c = categories[6]
    assert_equal 'ビジネス', c.display_name
    assert_nil c.name

    # response.categories[6].sub_categories
    scs = c.sub_categories
    assert_not_nil scs
    assert_equal 4, scs.size

    # response.categories[6].sub_categories[3]
    sc = scs[3]
    assert_equal 'work', sc.name
    assert_equal '仕事', sc.display_name
    assert_nil sc.sub_categories

  end


end
