defmodule Despamilator.Filter.TrailingNumberTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.TrailingNumber

  test "single match" do
    assert_filter_score(TrailingNumber, "hello 123", 0.1)
  end

  test "ignores urls" do
    assert_filter_score(TrailingNumber, "http://www.blah.com?x=2", 0)
  end
end
