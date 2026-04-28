defmodule Despamilator.Filter.MixedCaseTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.MixedCase

  test "single mixed-case word" do
    assert_filter_score(MixedCase, "yOu", 0.1)
  end

  test "two mixed-case words" do
    assert_filter_score(MixedCase, "yOu rulE", 0.2)
  end

  test "ignores urls" do
    assert_filter_score(MixedCase, "http://www.OhMyGod.com", 0)
  end
end
