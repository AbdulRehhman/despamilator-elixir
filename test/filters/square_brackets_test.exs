defmodule Despamilator.Filter.SquareBracketsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.SquareBrackets

  test "single bracket" do
    assert_filter_score(SquareBrackets, "[", 0.05)
  end

  test "two brackets" do
    assert_filter_score(SquareBrackets, "[]", 0.1)
  end
end
