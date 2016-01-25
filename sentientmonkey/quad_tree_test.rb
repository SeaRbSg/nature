require "minitest/autorun"
require "minitest/pride"

require_relative "quad_tree"

class QuadTreeTest < MiniTest::Test
  P1 = [50,50]
  P2 = [25,25]
  P3 = [75,75]
  P4 = [25,75]
  P5 = [75,25]
  POINTS = [P1,P2,P3,P4,P5]

  def setup
    @tree = QuadTree.new 100, 100
  end

  def add_all_points
    POINTS.each{|p| @tree.add p }
  end

  def test_find_point
    @tree.add P1
    p1 = @tree.find P1
    assert_equal P1, p1
  end

  def test_cant_find_missing_point
    p1 = @tree.find P1
    assert_nil p1
  end

  def test_contains
    assert @tree.contains? P1
  end

  def test_does_not_contain
    refute @tree.contains? [200,200]
  end

  def test_quad_split_can_still_find
    add_all_points
    POINTS.each{|p| assert_equal p, @tree.find(p) }
  end

  def test_quad_splits_into_proper_locations
    add_all_points
    assert_equal P2, @tree.root.quad[:SW].find(P2)
    assert_equal P3, @tree.root.quad[:NE].find(P3)
    assert_equal P4, @tree.root.quad[:NW].find(P4)
    assert_equal P5, @tree.root.quad[:SE].find(P5)
  end

  def test_quad_splits_midpoint_stays_in_all
    add_all_points
    assert_equal P1, @tree.root.quad[:SW].find(P1)
    assert_equal P1, @tree.root.quad[:NE].find(P1)
    assert_equal P1, @tree.root.quad[:NW].find(P1)
    assert_equal P1, @tree.root.quad[:SE].find(P1)
  end

  def test_find_closest
    skip
    add_all_points
    p = @tree.find_closest [30,30], 5
    assert_equal P2, p
  end
end
