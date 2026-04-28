defmodule Despamilator.Filter.NaughtyWordsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.NaughtyWords

  test "single naughty word" do
    assert_filter_score(NaughtyWords, "bondage", 0.1)
  end

  test "multiple naughty words" do
    assert_filter_score(NaughtyWords, "viagra penis", 0.2)
  end
end
