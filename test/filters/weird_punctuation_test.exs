defmodule Despamilator.Filter.WeirdPunctuationTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.WeirdPunctuation

  test "single match" do
    assert_filter_score(WeirdPunctuation, "&gt", 0.03)
  end

  test "five matches" do
    assert_filter_score(WeirdPunctuation, "%D :-D &gt;:-[ 123, l 89.", 0.15)
  end

  test "scores dots and commas mid word" do
    assert_filter_score(WeirdPunctuation, "aa.bb a,e", 0.06)
  end

  test "ignores weird punctuation in urls" do
    assert_filter_score(WeirdPunctuation, "http://www.blah.com?x=1&y=z", 0)
  end

  test "ignores initials" do
    assert_filter_score(WeirdPunctuation, "a.b.c", 0)
  end

  test "ignores ampersand surrounded by letters" do
    assert_filter_score(WeirdPunctuation, "j&r", 0)
  end

  test "ignores end of word quotes" do
    assert_filter_score(WeirdPunctuation, ~s('me' and "them"), 0)
  end

  test "ignores end of word commas and fullstops" do
    assert_filter_score(WeirdPunctuation, "that, that and that.", 0)
  end

  test "ignores end of word bangs and question marks" do
    assert_filter_score(WeirdPunctuation, "you there! will you stop?", 0)
  end

  test "ascii art signature" do
    assert_filter_score(
      WeirdPunctuation,
      """

      omg i love this stuff
      -+-+-+-+-+-+-+-
      some loser

      """,
      0.24
    )
  end
end
