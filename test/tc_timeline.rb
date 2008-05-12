# -*- coding: utf-8 -*-
#
#
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'webservice', 'timeline', 'api')

require 'date'
require 'test/unit'

class TimelineTest < Test::Unit::TestCase

  include TestHelper
  include WebService::TimeLine

  def test_readable_members
    t = Timeline.new
    members = t.readable_members
    assert_not_nil members
    assert members.empty?

    t.opened_for = 'user1'
    members = t.readable_members
    assert_equal 1, members.size
    assert_equal 'user1', members[0]

    t.opened_for = 'user1 user2'
    members = t.readable_members
    assert_equal 2, members.size
    assert_equal 'user1', members[0]
    assert_equal 'user2', members[1]

    t.opened_for = 'user1 user2 user3'
    members = t.readable_members
    assert_equal 3, members.size
    assert_equal 'user1', members[0]
    assert_equal 'user2', members[1]
    assert_equal 'user3', members[2]


    # writable members must appear in readable members list.
    t.opened_for = 'user1 user2 user3'
    t.locked_for = 'write1 write2 write3'
    members = t.readable_members.sort # original list is not sorted.
    assert_equal 6, members.size
    assert_equal 'user1', members[0]
    assert_equal 'user2', members[1]
    assert_equal 'user3', members[2]
    assert_equal 'write1', members[3]
    assert_equal 'write2', members[4]
    assert_equal 'write3', members[5]

    # 'rw1' and 'rw2' appear in both opened_for and locked_for.
    t.opened_for = 'user1 user2 user3 rw1 rw2'
    t.locked_for = 'write1 write2 write3 rw1 rw2'
    members = t.readable_members.sort # original list is not sorted.
    assert_equal 8, members.size
    assert_equal 'rw1', members[0]
    assert_equal 'rw2', members[1]
    assert_equal 'user1', members[2]
    assert_equal 'user2', members[3]
    assert_equal 'user3', members[4]
    assert_equal 'write1', members[5]
    assert_equal 'write2', members[6]
    assert_equal 'write3', members[7]
  end

  def test_writable_members
    t = Timeline.new
    members = t.writable_members
    assert_not_nil members
    assert members.empty?

    t.locked_for = 'write1'
    members = t.writable_members
    assert_equal 1, members.size
    assert_equal 'write1', members[0]

    t.locked_for = 'write1 write2'
    members = t.writable_members
    assert_equal 2, members.size
    assert_equal 'write1', members[0]
    assert_equal 'write2', members[1]

    t.locked_for = 'write1 write2 write3'
    members = t.writable_members
    assert_equal 3, members.size
    assert_equal 'write1', members[0]
    assert_equal 'write2', members[1]
    assert_equal 'write3', members[2]


    t.locked_for = 'write1 write2 write3'
    t.opened_for = 'read1 read2 read3'
    members = t.writable_members
    assert_equal 3, members.size
    assert_equal 'write1', members[0]
    assert_equal 'write2', members[1]
    assert_equal 'write3', members[2]
  end

  def test_commentable
    t = Timeline.new
    assert ! t.commentable?

    t.commentable = 'true'
    assert t.commentable?

    t.commentable = 'false'
    assert ! t.commentable?

    t.commentable = 'unknown-value'
    assert ! t.commentable?
  end
end
