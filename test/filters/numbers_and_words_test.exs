defmodule Despamilator.Filter.NumbersAndWordsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.NumbersAndWords

  test "single match" do
    assert_filter_score(NumbersAndWords, "X5T", 0.1)
  end

  test "multiple matches" do
    assert_filter_score(NumbersAndWords, "4g6hk", 0.2)
  end

  test "ignores urls" do
    assert_filter_score(NumbersAndWords, "http://www.blah7l.com", 0)
  end

  for n <- ["1", "4", "10", "100000", "1,000,000", "1st", "2nd", "3rd", "4th", "5th", "6th", "10th", "122nd"] do
    @num n
    test "ignores plain number #{n}" do
      assert_filter_score(NumbersAndWords, @num, 0)
    end
  end

  for tag_no <- 1..6 do
    @tag_no tag_no
    test "ignores html header tag h#{tag_no}" do
      assert_filter_score(NumbersAndWords, "h#{@tag_no}", 0)
    end
  end
end
