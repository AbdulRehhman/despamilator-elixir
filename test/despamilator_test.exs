defmodule DespamilatorTest do
  use ExUnit.Case, async: true

  alias Despamilator.Filter.GtubsTestFilter

  test "scores GTUBS string very high" do
    s = Despamilator.scan(Despamilator.gtubs_test_string())
    assert s.score >= 100.0
  end

  test "matches contains GTUBS filter for the magic string" do
    matches = Despamilator.matches(Despamilator.gtubs_test_string())
    assert Enum.any?(matches, &(&1.filter == GtubsTestFilter))
  end

  test "match map has filter and score" do
    [first | _] = Despamilator.matches(Despamilator.gtubs_test_string())
    assert first.filter == GtubsTestFilter
    assert first.score == 100.0
    assert first.filter.name() == "GTubs Test Filter"
    assert is_binary(first.filter.description())
  end

  test "score/1 helper" do
    assert Despamilator.score("hello") == 0.0
  end
end
