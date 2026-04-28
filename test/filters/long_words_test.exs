defmodule Despamilator.Filter.LongWordsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.LongWords

  test "single long word" do
    assert_filter_score(LongWords, "honorificabilitudinitatibus", 0.1)
  end

  test "multiple long words" do
    assert_filter_score(
      LongWords,
      "honorificabilitudinitatibus antidisestablishmentarianism",
      0.2
    )
  end

  test "ignores urls" do
    assert_filter_score(LongWords, "http://honorificabilitudinitatibus.com", 0)
  end
end
